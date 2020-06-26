import os, sys, wget, requests, shutil
from bs4 import BeautifulSoup
from zipfile import ZipFile

def check_clonezilla_update(zfs_pool):
    print("Checking for latest version of Clonezilla...")
    website_url = requests.get('https://clonezilla.org/downloads.php')
    soup = BeautifulSoup(website_url.content,'html5lib')
    latest_version = soup.find('a', attrs = {'href':'./downloads/download.php?branch=stable'}).find('font', attrs = {'color':'red'}).text
    if update_clonezilla(latest_version, zfs_pool):
        print("Clonezilla version " + latest_version + " installed successfully")
    else:
        print("Clonezilla install failed")

def update_clonezilla(latest_version, zfs_pool):
    print("Downloading Clonezilla " + latest_version + "...")
    url1 = 'http://free.nchc.org.tw/clonezilla-live/stable/clonezilla-live-' + str(latest_version) + '-amd64.zip'
    try:
        with open('/' + zfs_pool + '/tftp/clonezilla_download.zip', 'wb') as f:
            response = requests.get(url1, stream=True)
            total = response.headers.get('content-length')
            if total is None:
                f.write(response.content)
            else:
                downloaded = 0
                total = int(total)
                for data in response.iter_content(chunk_size=128):
                    downloaded += len(data)
                    f.write(data)
                    done = int(50*downloaded/total)
                    sys.stdout.write('\r[{}{}]'.format('█' * done, '.' * (50-done)))
                    sys.stdout.flush()
        sys.stdout.write('\n')
        #wget.download(url=url1, out='/' + zfs_pool + '/tftp/clonezilla_update.zip')
        print('done')
    except:
        print("unable to download Clonezilla update. Check Internet connection and run command ./ClonezillaInstall after reboot.")
        return False
    print("Extracting Clonezilla " + latest_version + "...", end='', flush=True)
    with ZipFile('/' + zfs_pool + '/tftp/clonezilla_download.zip', 'r') as zipObj:
        zipObj.extractall('/' + zfs_pool + '/tftp/clonezilla')
    print('done')
    print('Cleaning up...', end='', flush=True)
    os.remove('/' + zfs_pool + '/tftp/clonezilla_download.zip')
    print('done')
    return True

if __name__ == "__main__":
    zfs_pool = sys.argv[1]
    check_clonezilla_update(zfs_pool)
