# -*- coding:utf-8 -*
import urllib2
import re


def get_link():
    Month = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    Year = ["2013","2014", "2015","2016"]
    Page_link = []
    Time_lable = []
    for year in Year:
        for month in Month:
            temp = "http://www.dmf.go.th/service/monthlyPrice.php?m=" + str(month) + "&y=" + str(year) + "&ln=en"
            temp_time = str(year) + "-" + str(month) + "-01"
            Page_link.append(temp)
            Time_lable.append(temp_time)
    # already generate all page link and time

    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36'
    }
    contents = ["Time,","Field,","Curde_THB,","Curde_USD,","Condensate_USD,",
                "Condensate_THB,","Gas_THB,","Gas_USD,","LPG_HB,","LPG_USD\n"]
    for i in range(0,len(Page_link)-1):
    # for i in range(0, 2):
        request = urllib2.Request(Page_link[i], headers=headers)
        response = urllib2.urlopen(request)
        page = response.read()
        # print page
        pattern = re.compile('<td style="BORDER-BOTTOM: #773038 1px solid"><font face="tahoma" size=-1>(.*?)</font>')
        items = re.findall(pattern, page)
        t = 1
        for item in items:
            if t == 1:
                time_tag = str(Time_lable[i])+","
                contents.append(time_tag)
                item = str(item) + ","
                contents.append(item)
                t += 1
            elif t == 9:
                item = str(item) + "\n"
                contents.append(item)
                t = 1
            else:
                item = str(item) + ","
                contents.append(item)
                t += 1
        tag = "已经成功爬取泰国能源局官网"+str(Time_lable[i])+"的油价数据"
        print tag
        # print Page_link[i]
    # write data
    key = "Thailand oil price"
    tempfile = open(key + ".txt", "w+")
    for content in contents:
        tempfile.write(content)
    tempfile.close()

if __name__ == "__main__":
    get_link()
