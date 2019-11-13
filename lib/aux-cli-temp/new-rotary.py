from pigpio_encoder import pigpio_encoder

def rotary_callback(counter):
    print("Counter value: ", counter)

def sw_short():
    print("Switch short press")

def sw_long():
    print("Switch long press")

my_rotary = pigpio_encoder.Rotary(clk=17, dt=27, sw=22)
my_rotary.setup_rotary(min=10, max=300, scale=5, debounce=200, rotary_callback=rotary_callback)
my_rotary.setup_switch(debounce=200, long_press=True, sw_short_callback=sw_short, sw_long_callback=sw_long)

my_rotary.watch()