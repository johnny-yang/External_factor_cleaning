# -*- coding:utf-8 -*
import urllib2
import re
import string
from lxml import etree as etree


def copy_data():
    # Year = ["2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015",
    #         "2016","2017"]
    Year = ["2011", "2012", "2013", "2014", "2015", "2016", "2017"]
    Airport_code = ["ZSSS", "VABB", "YSSY", "VTBD", "ZBAA", "ZUUU", "ZGGG", "VIDD", "RCSS", "RPMM", "VVGL", "VVTS"]
    City_name = ["Shanghai", "Bombay", "Sydney", "Bangkok", "Beijing", "Chengdu", "Guangzhou",
                 "New Delhi", "Taibei", "Manila", "Ha Noi", "Ho Chi Minh"]
    # city - airport code
    # Shanghai ZSSS
    # Bombay VABB
    # Sydney YSSY
    # Bangkok VTBD
    # Beijing ZBAA
    # Chengdu ZUUU
    # Guangzhou ZGGG
    # New Delhi VIDD
    # Taibei RCSS
    # Manila RPMM
    # Ha Noi VVGL
    # Ho Chi Minh VVTS
    Page_link = []
    City_link_match = []
    for i in range(0, 12):
        for year_id in Year:
            if year_id == "2017" :
                # 手动修改最后一年时间
                temp = "https://www.wunderground.com/history/airport/" + str(Airport_code[i]) + "/"+str(int(year_id) - 1) + "/1/1/CustomHistory.html?dayend=10&monthend=1&yearend=" + str(year_id) + "&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=&format=1"
            else :
                temp = "https://www.wunderground.com/history/airport/" + str(Airport_code[i]) + "/"+str(int(year_id) - 1) + "/1/1/CustomHistory.html?dayend=1&monthend=1&yearend=" + str(year_id) + "&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=&format=1"
            Page_link.append(temp)
            City_link_match.append(City_name[i])
    contents = []
    for m in range(0,len(Page_link)):
        headers = {
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36'
        }
        request = urllib2.Request(Page_link[m], headers=headers)
        response = urllib2.urlopen(request)
        page = response.read()
        page = page.split('<br />')
        if m == 0:
            for t in range(0, len(page)-1):
                contents.append(page[t])
                contents.append(","+City_link_match[m])
        else :
            for t in range(1, len(page)-1):
                contents.append(page[t])
                contents.append(","+City_link_match[m])
        print Page_link[m]
    key = "Climate alternative data"
    tempfile = open(key + ".txt", "a")
    for content in contents:
        tempfile.write(content)
    tempfile.close()


if __name__ == "__main__":
    copy_data()




