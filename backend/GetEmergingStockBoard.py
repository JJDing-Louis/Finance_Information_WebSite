import json
import requests
from bs4 import BeautifulSoup

# 取得臺灣證券交易所公告內容(興櫃證券)
url = "https://isin.twse.com.tw/isin/C_public.jsp?strMode=5"

# All data infos
data = {}

print(f"Processing URL : {url}")

response = requests.get(url)
response.encoding = 'big5'  # 設定正確的編碼格式

# 使用 BeautifulSoup 解析 HTML
soup = BeautifulSoup(response.text, 'html.parser')
table = soup.find('table', {'class': 'h4'})

if table:
    for row in table.find_all('tr')[1:]:  # 跳過表頭
        cells = row.find_all('td')
        if len(cells) != 7:
            continue

        code, name = cells[0].text.split("\u3000")
        internationality = cells[1].text
        list_date = cells[2].text
        market_type = cells[3].text
        industry_type = cells[4].text

        data[code] = {
            "名稱": name,
            "代號": code,
            "市場別": market_type,
            "產業別": industry_type,
            "上市日期": list_date,
            "國際代碼": internationality
        }
    # 檔案落地
    with open("stock_infos.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("All data has been processed and saved to stock_infos.json")
else:
    print(f"Table not found for URL: {url}")