# WebScraping.py


# imports
import requests
from bs4 import BeautifulSoup


# spaghetti
page = requests.get("https://clexit.net/")

page.status_code # 200 is a good download
page.content # show all the content, inc tags 
soup = BeautifulSoup(page.content, 'html.parser')
print(soup.prettify())
list(soup.children)
[type(item) for item in list(soup.children)]
html = list(soup.children)[2]
list(html.children)
body = list(html.children)[3]
list(body.children)
p = list(body.children)[1]
p.get_text()

# find all instances of a tag
soup = BeautifulSoup(page.content, 'html.parser')
soup.find_all('p')

soup.find_all('p')[0].get_text()