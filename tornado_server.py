import tornado.ioloop
import tornado.web
from split import *
import json
import ast

class MainHandler(tornado.web.RequestHandler):
    def post(self):
        path_dict = self.request.body
        resp = split_pcap(path_dict.decode("utf-8") )
        self.write(resp)

def make_app():
    return tornado.web.Application([
        (r"/split", MainHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    print("Server Started")
    tornado.ioloop.IOLoop.current().start()



'''CURL Request
curl --header "Content-Type: application/json"   --request POST   --data '{"path":"<path>"}'   http://localhost:8888/split

example:
curl --header "Content-Type: application/json"   --request POST   --data '{"path":"/home/kali/Desktop/test1.pcap"}'   http://localhost:8888/split

'''
