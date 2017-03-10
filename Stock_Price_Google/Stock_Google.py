# -*- coding: utf-8 -*-
import urllib
from lxml import etree as etree
import requests
import re


def parse_html(cid, Index, Country):
    # 初始化
    start = 0
    filename = str(Country) + '.txt'
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36'
    }
    s = requests.get(get_link(cid, start), headers=headers)  # 开启VPN
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
        s = requests.get(get_link(cid, start), headers=headers)  # 开启VPN
        selector = etree.HTML(s.text)  # 开启VPN
        # 处理提取数据
        for m in range(2, 202):
            # 数据处理
            for i in range(1, 7):
                if i >= 1 & i <= 5:
                    tree_path = '//*[@id="prices"]/table/tr[' + str(m) + ']/td[' + str(i) + ']/text()'  # 开启VPN
                    content = selector.xpath(tree_path)
                    content = content[0]  # 开启VPN
                    content = data_cleaning(content) + '\t'
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
    s = requests.get(get_link(cid, start), headers=headers)  # 开启VPN
    selector = etree.HTML(s.text)  # 开启VPN
    end = (new_page - 200 * (j + 1) + 2)
    # 数据读写
    for m in range(2, end):
        for i in range(1, 7):
            if (i >= 1 & i <= 5):
                tree_path = '//*[@id="prices"]/table/tr[' + str(m) + ']/td[' + str(i) + ']/text()'  # 开启VPN
                content = selector.xpath(tree_path)
                content = content[0]  # 开启VPN
                content = data_cleaning(content) + '\t'
            if i == 6:
                content = str(Index) + '\t' + str(Country) + '\n'
            contents.append(content)
        tempfile = open(filename, "w+")
        for content in contents:
            tempfile.write(content)


def get_link(cid, start):
    # 生成网页链接
    url_base = 'https://www.google.com/finance/historical?'
    params = {'startdate': ['Jan 1, 2000'], 'num': 200, 'enddate': ['Jan 1, 2017'], 'cid': '15173681', 'start': 0}
    params['cid'] = str(cid)
    params['start'] = int(start)
    linkparse = urllib.urlencode(params)
    linkparse = url_base + linkparse
    tip = "正在访问页面：" + linkparse
    print tip
    return linkparse


def data_cleaning(content):
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


def Crawler_info():
    # 生成股票代码
    Indexcode = ['7521596', '14240693', '15173681', '15920262', '192906426752897', '9947405', '10240920']
    Indextag = ['SSE Composite Index', 'S&P/ASX 200', 'S&P BSE SENSEX', 'SZSE COMPOSITE INDEX', 'SET Index',
                'TSEC weighted index', 'S&P/NZX 50 Index Gross']
    Indexcountry = ['China-Shanghai', 'Austrilia', 'India', 'China-Shenzhen', 'Thailand', 'Taiwan', 'New zealand']
    for i in range(0, len(Indexcode)):
        begin_tip = "正在开始爬取" + str(Indexcountry[i] + "关于" + str(Indextag[i]) + "的数据")
        end_tip = "爬取完成"
        print begin_tip
        parse_html(Indexcode[i], Indextag[i], Indexcountry[i])
        print end_tip

        # google finance 数据代码
        # 7521596 - SSE Composite Index(SHA:000001) - China_Shanghai
        # 14240693 - S&P/ASX 200(INDEXASX:XJO) - Austrilia
        # 15173681 - S&P BSE SENSEX(INDEXBOM:SENSEX) - India
        # 15920262 - SZSE COMPOSITE INDEX(SHE:399106) - China_Shenzhen
        # 192906426752897 - SET Index(INDEXBKK:SET) - Thailand
        # 9947405 - TSEC weighted index(TPE:TAIEX) - Taiwan
        # 10240920 - S&P/NZX 50 Index Gross ( Gross Index )(NZE:NZ50G) - New zealand


if __name__ == '__main__':
    # parse_html(192906426752897, 'SET Index', 'Thailand')
    Crawler_info()
