import requests
import socket
import pandas as pd
import xml.etree.cElementTree as et
from tkinter import *
from tkinter import messagebox
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

def DownloadXML(URL = 'https://www.nbp.pl'+ getURL()):
    IPaddress = socket.gethostbyname(socket.gethostname())
    print(URL)
    if IPaddress == "127.0.0.1":
        print("No Internet connection: using the last data")
    else:
        response = requests.get(URL)
        with open('tabelka.xml', 'wb') as file:
            file.write(response.content)


def getFrame():
    prsXML = et.parse('tabelka.xml')
    dfcols = ['nazwa_waluty', 'przelicznik', 'kod_waluty', 'kurs_sredni']
    df_xml = pd.DataFrame(columns=dfcols)

    def getvalueofnode(node):
        """ return node text or None """
        return node.text if node is not None else None

    for node in prsXML.getroot():
        name = node.find('nazwa_waluty')
        przelicznik = node.find('przelicznik')
        kod = node.find('kod_waluty')
        kurs = node.find('kurs_sredni')
        df_xml = df_xml.append(
            pd.Series([getvalueofnode(name), getvalueofnode(przelicznik), getvalueofnode(kod), getvalueofnode(kurs)], index=dfcols), ignore_index=True)
    df_xml = df_xml.append(pd.Series({'nazwa_waluty':'polski zloty','przelicznik':'1','kod_waluty':'PLN','kurs_sredni':'1,0000'}),ignore_index=True)
    df_xml = df_xml[2:]

    return df_xml


def GUI():
    #important dataseries and list
    data = getFrame()
    list_names = list(data['nazwa_waluty'])

    # =------GUI-------=
    win = Tk()
    win.title('Konwerter walut')
    win.geometry('490x150+750+400') #dostosowane pod monitor 1920x1080
    win.resizable(width=False, height=False)
    win.iconbitmap(r'C:\Users\UserC\PycharmProjects\untitled\dollar.ico')

    label1 = Label(win, text = 'Wprowadź ile pieniędzy chcesz wymienić:')
    label2 = Label(win, text = 'Wybierz walutę, którą chcesz sprzedać:')
    label3 = Label(win, text = 'Wybierz walutę, którą chcesz kupić:')

    #----main constants-----
    e = Entry(win, textvariable=StringVar(), width = 36, justify = RIGHT)
    clicked1 = StringVar()
    clicked2 = StringVar()

    #-----main_command------
    def calculate():
        wprowadzona_wartosc = float(e.get())
        clicked_index1 = list_names.index(clicked1.get())
        clicked_index2 = list_names.index(clicked2.get())
        przelicznik1 = float(data.iloc[clicked_index1]['przelicznik'])
        przelicznik2 = float(data.iloc[clicked_index2]['przelicznik'])
        kod1 = data.iloc[clicked_index1]['kod_waluty']
        kod2 = data.iloc[clicked_index2]['kod_waluty']
        kurs1 = float((data.iloc[clicked_index1]['kurs_sredni']).replace(",","."))
        kurs2 = float((data.iloc[clicked_index2]['kurs_sredni']).replace(",","."))
        kurs3_jednostkowy = (kurs1/przelicznik1)/(kurs2/przelicznik2)
        result = round(wprowadzona_wartosc*kurs3_jednostkowy,2)
        messagebox.showinfo("Wynik","Za "+str(wprowadzona_wartosc)+
                                     kod1+" dostaniesz "+
                                     str(result)+ kod2)

    #-----DROPDOWN BARS-----------
    drop = OptionMenu(win, clicked1, *list_names)
    drop.config(width = 30 )
    drop2 = OptionMenu(win, clicked2,  *list_names)
    drop2.config(width = 30)

    #-----Calc BUTTON-----
    oblicz = Button(win, text ='Oblicz', command=calculate, bg = 'green',width = 30)


    #-----X-BUTTON-------
    quit_button = Button(win, text='EXIT', command=win.quit, bg = 'red')

    #---GRID----
    label1.grid(row = 1, column = 0)
    label2.grid(row = 2, column = 0)
    label3.grid(row = 3, column = 0)

    e.grid(row = 1, column = 1)

    drop.grid(row=2,column = 1)
    drop2.grid(row=3,column = 1)

    oblicz.grid(row=4,column = 1)
    quit_button.grid(row=0,column = 4)
    #---START---
    win.mainloop()

def main():
    DownloadXML()
    GUI()

if __name__ == "__main__":
    main()