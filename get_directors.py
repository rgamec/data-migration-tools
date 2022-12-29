# Quick script to populate a CVS of films with their directors.
#
# Input: MovieTitle,MovieYear
# Output: MovieTitle,MovieYear,Director(s)
#
# Uses OMDB - API_KEY needs to be defined with your own key.
import sys
import json
import requests
from requests.exceptions import HTTPError
import urllib.parse

API_KEY = "XXXXXX"

def parseCSV(csvFile):
    filmList = open(csvFile, 'r')
    Films = filmList.readlines()
    
    count = 0
    for film in Films:
        count += 1
        year = film.split(',')[-1].strip()
        title = ','.join(film.split(',')[:-1]).strip()
        metadata = fetchMetadata(title, year)
        print("{},{},{}".format(title, year, metadata))

def fetchMetadata(filmTitle, filmYear):
    #  http://www.omdbapi.com/?apikey=e417d01a&y=tt3896198
    encodedTitle = urllib.parse.quote(filmTitle)
    urlToCall = ("http://www.omdbapi.com/?apikey=" + API_KEY +
                "&t=" + encodedTitle +
                "&y=" + filmYear)

    try:
        response =  requests.get(urlToCall)
        response.raise_for_status()
        jsonResponse = response.json()
        try:
            return jsonResponse["Director"]
        except:
            return "Unknown"

    except HTTPError as http_err:
        print(f'HTTP Error Occured: {http_err}')
    except Exception as err:
        print(f'Other exception occurred: {err}')

    return 'Unknown'

def main():
    if len(sys.argv) < 2:
        exit("You need to pass in a CSV file")
    
    parseCSV(sys.argv[1])
    

if __name__ == "__main__":
    main()