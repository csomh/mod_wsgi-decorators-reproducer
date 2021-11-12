from flask import Flask

def tweak_init(cls):
    def new_init(inst, name):
        inst.text = f"Hello, {name}\n"

    cls.__init__ = new_init
    return cls

@tweak_init
class Greeting:
    pass

app = Flask(__name__)

@app.route("/")
def main():
    return Greeting("Pete").text
