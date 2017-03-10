# -*- coding: utf-8 -*-
import urllib
from selenium import webdriver
from lxml import etree as etree
import re




def parse_html(cid, Index, Country):
    start = 0
    filename = str(Country) + '.txt'
    # 使用selenium自动化驱动获取源代码
    s = get_source_proxy(get_link(cid, start)) # firefox 代理
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.98 Safari/537.36'
    }
    # proxy = {'http': 'http://10.139.152.222:3138',
    #          'https': 'http://10.139.152.222:3138' ,
    #          'ssl': 'http://10.139.152.222:3138',
    #          'ftp': 'http://10.139.152.222:3138'}
    # s = requests.get(get_link(cid, start), headers=headers)  # 开启VPN
    print ("已经成功解析源代码")

    # new_page = re.findall('200,\\n(.*?),', s.text, re.S)  # 开启VPN
    new_page = re.findall('200,\\n(.*?),', s, re.S) # firefox 代理
    new_page = int(new_page[0])
    page_info = "需要处理:" + str(new_page) + "行"
    print (page_info)
    j = new_page // 200
    end = j + 1
    page_information = "需要打开:" + str(end) + "页"
    print page_information
    contents = ["Date\t", "Open\t", "High\t", "Low\t", "Close\t","Index\t","Country\n"]
    # 处理有规律部分
    for j in range(0, end - 1):
        start = 200 * j
        s = get_source_proxy(get_link(cid, start))  # firefox 代理
        #s = requests.get(get_link(cid, start), headers=headers)  # 开启VPN
        #selector = etree.HTML(s.text)  # 开启VPN
        selector = etree.HTML(s)  # firefox 代理
        for m in range(2, 202):
            for i in range(1, 7):
                if (i >= 1 & i <= 5):
                    tree_path = '//*[@id="prices"]/table/tbody/tr[' + str(m) + ']/td[' + str(i) + ']/text()'  # 开启VPN
                    content = selector.xpath(tree_path)
                    content = content[0]
                    content = data_cleaning(content) + '\t'
                if i == 6:
                    content = str(Index) + '\t' + str(Country) + '\n'
                    # print content
                contents.append(content)
            tempfile = open(filename, "w+")
            for content in contents:
                tempfile.write(content)
    # 处理尾页
    start = 200 * (j + 1)
    s = get_source_proxy(get_link(cid, start))  # firefox 代理
    #s = requests.get(get_link(cid, start), headers=headers)  # 开启VPN
    #selector = etree.HTML(s.text)  # 开启VPN
    selector = etree.HTML(s)  # firefox 代理
    end = (new_page - 200 * (j + 1) + 2)
    for m in range(2, end):
        for i in range(1, 7):
            if (i >= 1 & i <= 5):
                tree_path = '//*[@id="prices"]/table/tbody/tr[' + str(m) + ']/td[' + str(i) + ']/text()'  # 开启VPN
                content = selector.xpath(tree_path)
                content = content[0]
                content = data_cleaning(content) + '\t'
            if i == 6:
                content = str(Index) + '\t' + str(Country) + '\n'
            contents.append(content)
        tempfile = open(filename, "w+")
        for content in contents:
            tempfile.write(content)


def get_link(cid, start):
    url_base = 'https://www.google.com/finance/historical?'
    params = {'startdate': ['Jan 1, 2000'], 'num': 200, 'enddate': ['Dec 15, 2016'], 'cid': '15173681', 'start': 0}
    params['cid'] = str(cid)
    params['start'] = int(start)
    linkparse = urllib.urlencode(params)
    linkparse = url_base + linkparse
    tip = "正在访问页面：" + linkparse
    print tip
    return linkparse


def get_source_proxy(url):
    # set proxy
    profile = webdriver.FirefoxProfile()
    # 设置代理
    profile.set_preference('network.proxy.type', 1)
    profile.set_preference('network.proxy.http', "10.139.152.222")
    profile.set_preference('network.proxy.http_port', 3138)
    profile.set_preference('network.proxy.ssl', "10.139.152.222")
    profile.set_preference('network.proxy.ssl_port', 3138)
    # profile.set_preference('network.proxy.socks', "10.139.152.222")
    # profile.set_preference('network.proxy.socks_port', 3138)
    # profile.set_preference('network.proxy.ftp', "10.139.152.222")
    # profile.set_preference('network.proxy.ftp_port', 3138)
    profile.update_preferences()
    # 实体化驱动器
    driver = webdriver.Firefox(executable_path='/Users/ValarMorghulis/Documents/selenium/geckodriver',
                               firefox_profile=profile)

    driver.get(url)
    driver.set_page_load_timeout(0.5)
    html_source = driver.page_source
    driver.quit()
    return html_source


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
    Indexcode = ['7521596', '14240693', '15173681', '15920262', '192906426752897', '9947405']
    Indextag = ['SSE Composite Index', 'S&P/ASX 200', 'S&P BSE SENSEX', 'SZSE COMPOSITE INDEX', 'SET Index',
                'TSEC weighted index']
    Indexcountry = ['China-Shanghai', 'Austrilia', 'India', 'China-Shenzhen', 'Thailand', 'Taiwan']
    for i in range(0, 6):
        begin_tip = "正在开始爬取" + str(Indexcountry[i] + "关于" + str(Indextag[i]) + "的数据")
        end_tip = "爬取完成"
        print begin_tip
        parse_html(Indexcode[i], Indextag[i], Indexcountry[i])
        print end_tip


        # 7521596 - SSE Composite Index(SHA:000001) - China_Shanghai
        # 14240693 - S&P/ASX 200(INDEXASX:XJO) - Austrilia
        # 15173681 - S&P BSE SENSEX(INDEXBOM:SENSEX) - India
        # 15920262 - SZSE COMPOSITE INDEX(SHE:399106) - China_Shenzhen
        # 192906426752897 - SET Index(INDEXBKK:SET) - Thailand
        # 9947405 - TSEC weighted index(TPE:TAIEX) - Taiwan


if __name__ == '__main__':
    # parse_html(15173681)
    # parse_html(14240693)
    parse_html(192906426752897, 'SET Index', 'Thailand')
    #Crawler_info()

