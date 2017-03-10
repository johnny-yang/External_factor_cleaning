# -*- coding: utf-8 -*-
from lxml import etree as etree
import requests
import urllib2
import urllib
import re


# Explaination
# Because i am leaving GTB , I have no time to write all codes well using Class.
# If all other interns have time to perfect my codes , you can do whatever you want.

def Control():
    # Fuel China control
    Fuel_China_list = ['20161215', '20161201', '20161117', '20161020', '20160919', '20160902', '20160819', '20160805',
                       '20160722',
                       '20160526', '20160512', '20160427', '20160114', '20151202',
                       '20151118', '20151104', '20151021', '20150917', '20150902', '20150819', '20150805', '20150722',
                       '20150708',
                       '20150609', '20150512', '20150425', '20150411', '20150327',
                       '20150228', '20150210', '20150127', '20150113', '20141227', '20141213', '20141115', '20141101',
                       '20141018',
                       '20140930', '20140917', '20140902', '20140819', '20140722',
                       '20140624', '20140523', '20140509', '20140425', '20140327', '20140227', '20140125', '20140111',
                       '20131213',
                       '20131129', '20131115', '20131101', '20130930', '20130914',
                       '20130831', '20130720', '20130706', '20130621', '20130607', '20130510', '20130425', '20130327',
                       '20130225',
                       '20121116', '20120911', '20120810', '20120711', '20120609',
                       '20120510', '20120320', '20120208', '20111009', '20110407', '20110220', '20101222', '20101026',
                       '20100601',
                       '20100414', '20091110', '20090930', '20090902', '20090729',
                       '20090630', '20090601', '20090325', '20090115', ]

    # Fuel Thailand control
    Fuel_Thailand_Month = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    Fuel_Thailand_Year = ["2013", "2014", "2015", "2016"]

    # Stock Google control
    Stock_google_startdate = 'Jan 1, 2000'
    Stock_google_enddate = 'Jan 1, 2017'

    # Weather main control
    Weather_Main_Cities = {"Shanghai": '583620', "Bombay": '430030', "Sydney": '947680', "Bangkok": '484550',
                           "Beijing": '545110',
                           "Chengdu": '562940', "Guangzhou": '592870', "New Delhi": '421810', "Taibei": '589680',
                           "Manila": '984250',
                           "Ha Noi": '488200', "Ho Chi Minh": '489000'}
    Weather_Main_MMMonth = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
    Weather_Main_YYYear = ['2011', '2012', '2013', '2014', '2015', '2016', '2017']
    Weather_Main_endyear = "2017"
    Weather_Main_endmonth = "04"

    # Weather alternative control
    # Weather_Alternative_Year = ["2011", "2012", "2013", "2014", "2015", "2016", "2017"]
    Weather_Alternative_Year = [ "2016", "2017"]

    Weather_Alternative_Dayend = 10
    Weather_Alternative_Monthend = 3

    # execution
    # Fuel_China(Fuel_China_list)
    # print ("\n\n中国油价数据已经爬取完毕\n\n")
    # Stock_Google(Stock_google_startdate, Stock_google_enddate)
    # print ("\n\nGoogle股价数据已经爬取完毕\n\n")
    # Fuel_Thailand(Fuel_Thailand_Month, Fuel_Thailand_Year)
    # print ("\n\n泰国油价数据已经爬取完毕\n\n")
    Weather_Alternative(Weather_Alternative_Year, Weather_Alternative_Dayend, Weather_Alternative_Monthend)
    print ("\n\n天气备用数据已经爬取完毕\n\n")
    # Weather_Main_Execution(Weather_Main_Cities, Weather_Main_MMMonth, Weather_Main_YYYear,Weather_Main_endyear,Weather_Main_endmonth)
    # print ("\n\n天气主要数据已经爬取完毕\n\n")
    #

# notice Chinese fuel price will be controlled by the exact date
def Fuel_China(list):
    filename = "Fuel_China/China oil price.txt"
    # 东方财富网所有时间列表
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36'
    }
    # 创建城市列表
    city = ["", "", "", "", "北京\t", "上海\t", "天津\t",
            "南京\t", "沈阳\t", "重庆\t", "西安\t",
            "青岛\t", "浙江\t", "成都\t", "济南\t"]
    # 写入数据
    content = ["Date\t", "City\t", "90#\t", "92#\t", "95#\t", "0#\n"]
    for html in list:
        source = "http://data.eastmoney.com/OilPrice/oil_date.aspx?date=" + html
        print source
        s = requests.get(source, headers=headers)
        selector = etree.HTML(s.text)
        for i in range(4, 15):
            date = html + "\t"
            content.append(date)
            content.append(city[i])
            for m in [3, 6, 9, 12]:
                if m == 12:
                    tree_path = '//*[@id="right_box2"]/div[3]/table/tr[' + str(i) + ']/td[' + str(m) + ']/text()'
                    temp = selector.xpath(tree_path)
                    if temp:
                        temp = temp[0] + "\n"
                    else:
                        temp = "\n"
                    content.append(temp)
                else:
                    tree_path = '//*[@id="right_box2"]/div[3]/table/tr[' + str(i) + ']/td[' + str(m) + ']/text()'
                    temp = selector.xpath(tree_path)
                    if temp:
                        temp = temp[0] + "\t"
                    else:
                        temp = "\t"
                    content.append(temp)
    tempfile = open(filename, "w+")
    for t in content:
        tempfile.write(t)


def Stock_Google_parse_html(cid, Index, Country, start_date, end_date):
    # 初始化
    start = 0
    filename = 'Stock_Price_Google/' + str(Country) + '.txt'
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36'
    }
    s = requests.get(Stock_Google_get_link(cid, start, start_date, end_date), headers=headers)  # 开启VPN
    print ("已经成功解析源代码")
    # 计算页码
    new_page = re.findall('200,\\n(.*?),', s.text, re.S)  # 开启VPN
    new_page = int(new_page[0])
    page_info = "需要处理:" + str(new_page) + "行"
    print (page_info)
    j = new_page // 200
    end = j + 1
    page_information = "需要打开:" + str(end) + "页"
    print page_information
    # 设置文本标题行
    contents = ["Date\t", "Open\t", "High\t", "Low\t", "Close\t", "Index\t", "Country\n"]
    # 数据处理
    for j in range(0, end - 1):
        # 解析源代码
        start = 200 * j
        s = requests.get(Stock_Google_get_link(cid, start, start_date, end_date), headers=headers)  # 开启VPN
        selector = etree.HTML(s.text)  # 开启VPN
        # 处理提取数据
        for m in range(2, 202):
            # 数据处理
            for i in range(1, 7):
                if i >= 1 & i <= 5:
                    tree_path = '//*[@id="prices"]/table/tr[' + str(m) + ']/td[' + str(i) + ']/text()'  # 开启VPN
                    content = selector.xpath(tree_path)
                    content = content[0]  # 开启VPN
                    content = Stock_Google_data_cleaning(content) + '\t'
                if i == 6:
                    content = str(Index) + '\t' + str(Country) + '\n'
                    # print content
                contents.append(content)
            # 数据写入
            tempfile = open(filename, "w+")
            for content in contents:
                tempfile.write(content)

    ### 处理尾页
    # 重新初始化
    start = 200 * (j + 1)
    s = requests.get(Stock_Google_get_link(cid, start, start_date, end_date), headers=headers)  # 开启VPN
    selector = etree.HTML(s.text)  # 开启VPN
    end = (new_page - 200 * (j + 1) + 2)
    # 数据读写
    for m in range(2, end):
        for i in range(1, 7):
            if (i >= 1 & i <= 5):
                tree_path = '//*[@id="prices"]/table/tr[' + str(m) + ']/td[' + str(i) + ']/text()'  # 开启VPN
                content = selector.xpath(tree_path)
                content = content[0]  # 开启VPN
                content = Stock_Google_data_cleaning(content) + '\t'
            if i == 6:
                content = str(Index) + '\t' + str(Country) + '\n'
            contents.append(content)
        tempfile = open(filename, "w+")
        for content in contents:
            tempfile.write(content)


# For better control my shell , I add start_date and end_date
def Stock_Google_get_link(cid, start, start_date, end_date):
    # 生成网页链接
    url_base = 'https://www.google.com/finance/historical?'
    params = {'startdate': ['Jan 1, 2000'], 'num': 200, 'enddate': ['Jan 1, 2017'], 'cid': '15173681', 'start': 0}
    params['cid'] = str(cid)
    params['start'] = int(start)
    params['startdate'] = str(start_date)
    params['enddate'] = str(end_date)
    linkparse = urllib.urlencode(params)
    linkparse = url_base + linkparse
    tip = "正在访问页面：" + linkparse
    print tip
    return linkparse


def Stock_Google_data_cleaning(content):
    # 整理为 12-1-2016 形式，并去掉换行符
    content = content.replace("\n", "")
    content = content.replace("Dec", "12")
    content = content.replace("Nov", "11")
    content = content.replace("Oct", "10")
    content = content.replace("Sep", "09")
    content = content.replace("Aug", "08")
    content = content.replace("Jul", "07")
    content = content.replace("Jun", "06")
    content = content.replace("May", "05")
    content = content.replace("Apr", "04")
    content = content.replace("Mar", "03")
    content = content.replace("Feb", "02")
    content = content.replace("Jan", "01")
    content = content.replace(",", "")
    content = content.replace(" ", "-")
    return content


def Stock_Google(start_date, end_date):
    # 生成股票代码
    Indexcode = ['7521596', '14240693', '15173681', '15920262', '192906426752897', '9947405', '10240920']
    Indextag = ['SSE Composite Index', 'S&P/ASX 200', 'S&P BSE SENSEX', 'SZSE COMPOSITE INDEX', 'SET Index',
                'TSEC weighted index', 'S&P/NZX 50 Index Gross']
    Indexcountry = ['China-Shanghai', 'Austrilia', 'India', 'China-Shenzhen', 'Thailand', 'Taiwan', 'New zealand']
    for i in range(0, len(Indexcode)):
        begin_tip = "正在开始爬取" + str(Indexcountry[i] + "关于" + str(Indextag[i]) + "的数据")
        end_tip = "爬取完成"
        print begin_tip
        Stock_Google_parse_html(Indexcode[i], Indextag[i], Indexcountry[i],start_date,end_date)
        print end_tip

        # google finance 数据代码
        # 7521596 - SSE Composite Index(SHA:000001) - China_Shanghai
        # 14240693 - S&P/ASX 200(INDEXASX:XJO) - Austrilia
        # 15173681 - S&P BSE SENSEX(INDEXBOM:SENSEX) - India
        # 15920262 - SZSE COMPOSITE INDEX(SHE:399106) - China_Shenzhen
        # 192906426752897 - SET Index(INDEXBKK:SET) - Thailand
        # 9947405 - TSEC weighted index(TPE:TAIEX) - Taiwan
        # 10240920 - S&P/NZX 50 Index Gross ( Gross Index )(NZE:NZ50G) - New zealand


def Fuel_Thailand(Month, Year):
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
    contents = ["Time,", "Field,", "Curde_THB,", "Curde_USD,", "Condensate_USD,",
                "Condensate_THB,", "Gas_THB,", "Gas_USD,", "LPG_HB,", "LPG_USD\n"]
    for i in range(0, len(Page_link) - 1):
        # for i in range(0, 2):
        # 2017/03/08 这里重新修正了原来的代码，headers会报错因此删除了
        # request = urllib2.Request(Page_link[i],headers = headers)
        request = urllib2.Request(Page_link[i])
        page = urllib2.urlopen(request).read()
        # print page
        pattern = re.compile('<td style="BORDER-BOTTOM: #773038 1px solid"><font face="tahoma" size=-1>(.*?)</font>')
        items = re.findall(pattern, page)
        t = 1
        for item in items:
            if t == 1:
                time_tag = str(Time_lable[i]) + ","
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
        tag = "已经成功爬取泰国能源局官网" + str(Time_lable[i]) + "的油价数据"
        print tag
        # print Page_link[i]
    # write data
    key = "Fuel_Thailand/Thailand oil price"
    tempfile = open(key + ".txt", "w+")
    for content in contents:
        tempfile.write(content)
    tempfile.close()


class Weather_Main_Tool:
    removeImg = re.compile('<img.*?>| {7}|')
    removeAddr = re.compile('<a.*?>|</a>')
    replaceLine = re.compile('<tr>|<div>|</div>|</p>')
    replaceTD = re.compile('<td>')
    replacePara = re.compile('<p.*?>')
    replaceBR = re.compile('<br><br>|<br>')
    removeExtraTag = re.compile('<.*?>')
    replaceTags = re.compile('(Day)|T|M|SLP|H|[PP]|V|(VM)|G|RA|S|N|F')
    replancem = re.compile("m")

    def replace(self, x):
        x = re.sub(self.removeImg, "", x)
        x = re.sub(self.removeAddr, "", x)
        x = re.sub(self.replaceLine, "\n", x)
        x = re.sub(self.replaceTD, "\t", x)
        x = re.sub(self.replacePara, "\n", x)
        x = re.sub(self.replaceBR, "\n", x)
        x = re.sub(self.removeExtraTag, "", x)
        x = re.sub(self.replaceTags, "", x)
        x = re.sub(self.replancem, "Here comes another month", x)
        return x.strip()


class Weather_Main:
    def __init__(self, WeatherStationNo):
        self.WSN = WeatherStationNo
        self.baseUrl = 'http://en.tutiempo.net/climate/'
        self.Weather_Main_Tool = Weather_Main_Tool()

    def getPage(self, Year, Month):
        try:
            url = self.baseUrl + Month + '-' + Year + '/ws-' + self.WSN + ".html"
            request = urllib2.Request(url)
            response = urllib2.urlopen(request)
            # print response.read()
            return response.read()
        except urllib2.URLError, e:
            if hasattr(e, "reason"):
                print u"Connceting Fail, because", e.reason
                return None

    def getContent(self,page, City ,year, month):
        pattern = re.compile(
            '<table cellpadding="0" class="medias mensuales" style="width:100%;" cellspacing="0">(.*?)<th colspan="15" style="height:30px;">',
            re.S)
        items = re.findall(pattern, page)
        contents = []
        for item in items:
            content = '\n' + self.Weather_Main_Tool.replace(item)
            Date = '\n' + year + '/' + month + '/01'
            contents.append(Date + '\t' + content)
            tag = "已经成功存储" +City+"在"+ year + "-" + month + "的天气数据了"
            print tag
        return contents


def Weather_Main_Execution(Cities, MMMonth, YYYear,end_year,end_month):
    for key in Cities.keys():
        tempfile = open("Weather_crawler_Main/" + key + ".txt", "w+")
        tempfile.write("City of " + key + ", WSN: " + Cities[key])
        for year in YYYear:
            for month in MMMonth:
                if (year == end_year and month == end_month):
                    break
                currentciti = Weather_Main(Cities[key])
                temp = currentciti.getContent(currentciti.getPage(year, month),key,year, month)
                for kkk in temp:
                    tempfile.write(kkk)
        tempfile.close()


def Weather_Alternative(Year, dayend, monthend):
    # Year = ["2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015",
    #         "2016","2017"]
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
            if year_id == Year[len(Year)-1]:
                # 手动修改最后一年时间
                temp = "https://www.wunderground.com/history/airport/" + str(Airport_code[i]) + "/" + str(
                    int(year_id) - 1) + "/1/1/CustomHistory.html?dayend=" + str(dayend) + "&monthend=" + str(
                    monthend) + "&yearend=" + str(year_id) + "&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=&format=1"
            else:
                temp = "https://www.wunderground.com/history/airport/" + str(Airport_code[i]) + "/" + str(
                    int(year_id) - 1) + "/1/1/CustomHistory.html?dayend=1&monthend=1&yearend=" + str(
                    year_id) + "&req_city=&req_state=&req_statename=&reqdb.zip=&reqdb.magic=&reqdb.wmo=&format=1"
            Page_link.append(temp)
            City_link_match.append(City_name[i])
    contents = []
    for m in range(0, len(Page_link)):
        headers = {
            'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36'
        }
        request = urllib2.Request(Page_link[m], headers=headers)
        response = urllib2.urlopen(request)
        page = response.read()
        page = page.split('<br />')
        if m == 0:
            for t in range(0, len(page) - 1):
                contents.append(page[t])
                contents.append("," + City_link_match[m])
        else:
            for t in range(1, len(page) - 1):
                contents.append(page[t])
                contents.append("," + City_link_match[m])
        print Page_link[m]
    key = "Weather_crawler_Alternative/Climate alternative data"
    tempfile = open(key + ".txt", "w+")
    for content in contents:
        tempfile.write(content)
    tempfile.close()


if __name__ == '__main__':
    Control()
