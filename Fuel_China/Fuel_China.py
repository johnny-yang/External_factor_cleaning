# -*- coding: utf-8 -*-
from lxml import etree as etree
import requests


# def get_url():
#     original_html = "http://data.eastmoney.com/OilPrice/oil_date.aspx?date="
#     year = ["2016", "2015", "2014", "2013", "2012", "2011", "2010", "2009", ]
#     month = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
#     day = ['01', '02', '03', '04', '05', '06', '07', '08', '09',
#            '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26',
#            '27', '28', '29', '30', '31']
#     content = []
#     for d in day:
#         for m in month:
#             for y in year:
#                 html = original_html + y + m + d
#                 content.append(html)
#     return content


def get_content():
    filename = "China oil price.txt"
    # 东方财富网所有时间列表
    list = ['20161215', '20161201', '20161117', '20161020', '20160919', '20160902', '20160819', '20160805', '20160722',
            '20160526', '20160512', '20160427', '20160114', '20151202',
            '20151118', '20151104', '20151021', '20150917', '20150902', '20150819', '20150805', '20150722', '20150708',
            '20150609', '20150512', '20150425', '20150411', '20150327',
            '20150228', '20150210', '20150127', '20150113', '20141227', '20141213', '20141115', '20141101', '20141018',
            '20140930', '20140917', '20140902', '20140819', '20140722',
            '20140624', '20140523', '20140509', '20140425', '20140327', '20140227', '20140125', '20140111', '20131213',
            '20131129', '20131115', '20131101', '20130930', '20130914',
            '20130831', '20130720', '20130706', '20130621', '20130607', '20130510', '20130425', '20130327', '20130225',
            '20121116', '20120911', '20120810', '20120711', '20120609',
            '20120510', '20120320', '20120208', '20111009', '20110407', '20110220', '20101222', '20101026', '20100601',
            '20100414', '20091110', '20090930', '20090902', '20090729',
            '20090630', '20090601', '20090325', '20090115', ]
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


if __name__ == '__main__':
    get_content()
    # parse_html(192906426752897, 'SET Index', 'Thailand')
