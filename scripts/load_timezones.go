// Script for working with GeoName dumps from https://download.geonames.org/export/dump/readme.txt

package main

import (
	"archive/zip"
	"bufio"
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"runtime"
	"sort"
	"strings"
	"time"
)

type rawTimeZone struct {
	Name               string   `json:"name"`
	MainCities         []string `json:"mainCities"`
	CountryCode        string   `json:"countryCode"`
	RawOffsetInMinutes int      `json:"rawOffsetInMinutes"`
	RawFormat          string   `json:"rawFormat"`
}

type zoneKey struct{ timeZone, countryCode string }

// The main 'geoname' table has the following fields :
// ---------------------------------------------------
// geonameid         : integer id of record in geonames database
// name              : name of geographical point (utf8) varchar(200)
// asciiname         : name of geographical point in plain ascii characters, varchar(200)
// alternatenames    : alternatenames, comma separated, ascii names automatically transliterated, convenience attribute from alternatename table, varchar(10000)
// latitude          : latitude in decimal degrees (wgs84)
// longitude         : longitude in decimal degrees (wgs84)
// feature class     : see http://www.geonames.org/export/codes.html, char(1)
// feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
// country code      : ISO-3166 2-letter country code, 2 characters
// cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 200 characters
// admin1 code       : fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)
// admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80)
// admin3 code       : code for third level administrative division, varchar(20)
// admin4 code       : code for fourth level administrative division, varchar(20)
// population        : bigint (8 byte int)
// elevation         : in meters, integer
// dem               : digital elevation model, srtm3 or gtopo30, average elevation of 3”x3” (ca 90mx90m) or 30”x30” (ca 900mx900m) area in meters, integer. srtm processed by cgiar/ciat.
// timezone          : the iana timezone id (see file timeZone.txt) varchar(40)
// modification date : date of last modification in yyyy-MM-dd format
const (
	nameIdx        = 1
	countryCodeIdx = 8
	tzIdx          = 17
)

func main() {
	input := flag.String("in", "", "input file (.txt), will download if blank")
	flag.Parse()

	data, err := load(*input, "cities15000")
	if err != nil {
		log.Fatal(err)
		os.Exit(1)
	}

	cities, err := parseCities(data)
	if err != nil {
		log.Fatal(err)
	}

	zones := buildZones(cities)

	path := outputPath()
	if err := writeJSON(path, zones); err != nil {
		log.Fatal(err)
	}

	fmt.Fprintf(os.Stderr, "wrote %d time zones to %s\n", len(zones), path)
}

func outputPath() string {
	_, scriptPath, _, _ := runtime.Caller(0)
	return filepath.Join(filepath.Dir(scriptPath), "..", "ManyTime", "Data", "RawTimeZones.json")
}

func download(url string) ([]byte, error) {
	client := &http.Client{Timeout: 2 * time.Minute}
	resp, err := client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Failed to GET %s: %s", url, resp.Status)
	}
	return io.ReadAll(resp.Body)
}

func load(input, dataset string) ([]byte, error) {
	var raw []byte
	var err error

	if input != "" {
		fmt.Fprintf(os.Stderr, "loading %s\n", input)
		raw, err = os.ReadFile(input)
		if err != nil {
			return nil, err
		}
		return raw, nil
	} else {
		url := fmt.Sprintf("https://download.geonames.org/export/dump/%s.zip", dataset)
		fmt.Fprintf(os.Stderr, "downloading %s\n", url)
		raw, err = download(url)
		if err != nil {
			return nil, err
		}
	}

	z, err := zip.NewReader(bytes.NewReader(raw), int64(len(raw)))
	if err != nil {
		return nil, err
	}

	filename := fmt.Sprintf("%s.txt", dataset)
	for _, f := range z.File {
		if f.Name != filename {
			continue
		}

		rc, err := f.Open()
		if err != nil {
			return nil, err
		}

		defer rc.Close()
		return io.ReadAll(rc)
	}

	return nil, fmt.Errorf("%s not found", filename)
}

func parseCities(text []byte) (map[zoneKey][]string, error) {
	cities := map[zoneKey][]string{}
	seen := map[string]bool{}

	scanner := bufio.NewScanner(bytes.NewReader(text))
	scanner.Buffer(make([]byte, 0, 64*1024), 4*1024*1024)
	for scanner.Scan() {
		fields := strings.Split(scanner.Text(), "\t")
		if len(fields) < 18 || fields[nameIdx] == "" || fields[countryCodeIdx] == "" || fields[tzIdx] == "" {
			continue
		}
		name, country, zone := fields[nameIdx], fields[countryCodeIdx], fields[tzIdx]

		id := strings.ToLower(name) + country + zone
		if seen[id] {
			continue
		}
		seen[id] = true

		key := zoneKey{zone, country}
		cities[key] = append(cities[key], name)
	}
	return cities, scanner.Err()
}

func buildZones(cities map[zoneKey][]string) []rawTimeZone {
	var zones []rawTimeZone

	for key, names := range cities {
		location, err := time.LoadLocation(key.timeZone)
		if err != nil {
			log.Printf("skipping unknown time zone %s", key.timeZone)
			continue
		}

		sort.Strings(names)
		offset := standardOffsetMinutes(location)
		zones = append(zones, rawTimeZone{
			Name:               key.timeZone,
			MainCities:         names,
			CountryCode:        key.countryCode,
			RawOffsetInMinutes: offset,
			RawFormat:          gmtOffset(offset) + " " + key.timeZone,
		})
	}

	sort.Slice(zones, func(i, j int) bool {
		if zones[i].Name != zones[j].Name {
			return zones[i].Name < zones[j].Name
		}
		return zones[i].CountryCode < zones[j].CountryCode
	})
	return zones
}

func standardOffsetMinutes(location *time.Location) int {
	year := time.Now().Year()
	_, january := time.Date(year, time.January, 1, 12, 0, 0, 0, time.UTC).In(location).Zone()
	_, july := time.Date(year, time.July, 1, 12, 0, 0, 0, time.UTC).In(location).Zone()
	return min(january, july) / 60
}

func gmtOffset(minutes int) string {
	sign := "+"
	if minutes < 0 {
		sign, minutes = "-", -minutes
	}
	return fmt.Sprintf("%s%02d:%02d", sign, minutes/60, minutes%60)
}

func writeJSON(output string, zones []rawTimeZone) error {
	data, err := json.MarshalIndent(zones, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(output, data, 0o644)
}
