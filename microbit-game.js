basic.forever(() => {
    while (input.buttonIsPressed(Button.AB)) {
        serial.writeLine("c")
        basic.pause(100)
    }
    while (input.buttonIsPressed(Button.A)) {
        serial.writeLine("a")
    }
    while (input.buttonIsPressed(Button.B)) {
        serial.writeLine("b")
    }
})
