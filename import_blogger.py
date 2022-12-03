import feedparser
import sys
import json

def loadXML():
    # Load our XML file
    print('hello')

def parseXML(xmlFile):
    # parse our XML file
    # Need to pull out: post content, publication date, post title, draft status

    tags_to_exclude = []
    tags_to_include = ['http://schemas.google.com/blogger/2008/kind#post']

    posts = []
    count = 0
    d = feedparser.parse(xmlFile)
    for entry in d.entries:

        for tag in entry.tags:
            if tag.term in tags_to_include:
                postContent = entry.content[0]['value'][:100]
                postTitle = entry.title
                postPublishedDate = entry.published

                postObject =  {'postContent': postContent,
                               'postTitle': postTitle,
                               'postPublishedDate': postPublishedDate }
                posts.append(postObject)
        count = count + 1
    
    print(json.dumps(posts))

def main():
    if len(sys.argv) < 2:
        exit("You need to pass in an XML file")
    
    parseXML(sys.argv[1])
    

if __name__ == "__main__":
    # calling main function
    main()
