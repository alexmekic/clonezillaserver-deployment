import os, wget, requests, shutil
from bs4 import BeautifulSoup
from zipfile import ZipFile

def check_clonezilla_update():
    print("Checking for latest version of Clonezilla...")
    website_url = requests.get('https://clonezilla.org/downloads.php')
    soup = BeautifulSoup(website_url.content,'html5lib')
    latest_version = soup.find('a', attrs = {'href':'./downloads/download.php?branch=stable'}).find('font', attrs = {'color':'red'}).text
    if update_clonezilla(latest_version):
        print("Clonezilla version " + latest_version + " installed successfully")
    else:
        print("Clonezilla installed failed")

def update_clonezilla(latest_version):
    print("Downloading Clonezilla " + latest_version + "...")
    url1 = 'http://free.nchc.org.tw/clonezilla-live/stable/clonezilla-live-' + str(latest_version) + '-amd64.zip'
    try:
        wget.download(url=url1, out='/pxe/tftp/clonezilla_update.zip')
        print('done')
    except:
        print("unable to download Clonezilla update. Type in the command ./ClonezillaInstall to try again after deploymemt.")
        return False
    print("Extracting Clonezilla " + latest_version + "...", end='', flush=True)
    with ZipFile('/pxe/tftp/clonezilla_update.zip', 'r') as zipObj:
        zipObj.extractall('/pxe/tftp/clonezilla')
    print('done')
    print('Cleaning up...', end='', flush=True)
    os.remove('/pxe/tftp/clonezilla_update.zip')
    print('done')
    return True

if __name__ == "__main__":
    check_clonezilla_update()
