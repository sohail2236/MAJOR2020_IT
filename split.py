import os
import numpy
import binascii
from array import *
from PIL import Image


def split_pcap(path):
    if not os.path.exists(os.getcwd()+"/split_pcap_folder"):
        os.mkdir(os.getcwd()+"/split_pcap_folder")
    if not os.path.exists(os.getcwd()+"/binary_file"):
        os.mkdir(os.getcwd()+"/binary_file")
    if not os.path.exists(os.getcwd()+"/PNG_file"):
        os.mkdir(os.getcwd()+"/PNG_file")
    if not os.path.exists(os.getcwd()+"/mnist_data"):
        os.mkdir(os.getcwd()+"/mnist_data")
    try:
        dict_obj = dict()
        temp = os.getcwd()
        temp2=os.listdir(temp)
        print(path)
        os.system("mono SplitCap.exe -p 10 -b 10 -r {} -o split_pcap_folder -y L7".format(path))
        print('Done')
        for i in os.listdir(os.getcwd()+'/split_pcap_folder'):
            data_array=array('B')
            bin_path = os.getcwd()+'/split_pcap_folder/'+i
            #f = open(bin_path,'rb')
            data = arrayfrom_pcap(bin_path)
            im=Image.fromarray(data)
            data_array=data
            name = i.split('.')[2]
            data_path_open = open(os.getcwd()+'/binary_file/'+name+'.bin', 'wb')
            data_array.tofile(data_path_open)
            data_path_open.close()
            im.save(os.getcwd()+'/PNG_file/'+name+'.png')
            dict_obj[name]=os.getcwd()+'/PNG_file/'+name+'.png'
        response = create_mnist(dict_obj, os.getcwd()+"/mnist_data/")
        print('Exiting')
        return response
    except Exception as e:
        print("Splitting Failed")
        print(e)


#Copied
def arrayfrom_pcap(filename,width=28):
    with open(filename, 'rb') as f:
        content = f.read()
    if len(content) >= 784:
        content = content[0:784]
    elif len(content) < 784:
        content = content + b'\x00'*(784-len(content))
    hexst = binascii.hexlify(content)
    fh = numpy.array([int(hexst[i:i+2],16) for i in range(0, len(hexst), 2)])
    rn = int(len(fh)/width)
    fh = numpy.reshape(fh[:rn*width],(-1,width))
    fh = numpy.uint8(fh)
    return fh


def create_mnist(data_dict:dict, path:str):
    path_list = list()
    mnist_data = array('B')
    result = dict()
    i=0
    for k,v in data_dict.items():
        path_list.append(k)
        im_buffer  = Image.open(v)
        im_data = im_buffer.load()
        x,y = im_buffer.size
        i=i+1
        for i in range(0,x):
            for j in range(0,y):
                mnist_data.append(im_data[j,i])
    hexval = "{0:#0{1}x}".format(i, 6)
    header = array('B')
    header.extend([0, 0, 8, 1, 0, 0])
    header.append(int('0x' + hexval[2:][:2], 16))
    header.append(int('0x' + hexval[2:][2:], 16))
    if max([x, y]) <= 256:
        header.extend([0, 0, 0, x, 0, 0, 0, y])
    else:
        raise ValueError("Error____________:P")
    header[3] = 3
    mnist_data = header+mnist_data
    output_file = open(path + 'output-idx3-ubyte', 'wb')
    mnist_data.tofile(output_file)
    output_file.close()
    result["list"] = path_list
    result["path"] = path + 'output-idx3-ubyte'
    return result

