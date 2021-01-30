import requests
from bs4 import BeautifulSoup

def getURL(url = 'https://www.nbp.pl/kursy/kursya.html'):
    r = requests.get(url)
    html = r.text
    soup = BeautifulSoup(html, 'html.parser')
    a=[]
    for link in soup.find_all('a'):
        a.append(link.get('href'))
    for i in a:
        if '/kursy/xml/' in i:
            return i
print(type(getURL()))
