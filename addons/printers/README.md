# Printers

Adds ability to print documents using placeable printers. This is primarily built ontop of the QBCore/qb-printer implementation with some modifications to remove QBCore as a framework dependency. 

## Usage

- Place the printer
- Interact with the printer and select "Use printer"
- Input the URL to the document you wish to print
- The player is given a unique `printerdocument` with metadata attached to it
- When players view the document, they will see what was printed to the document

## Setup

> If you already have qb-printer or a related printer script, then you can either disable that script and use the implementation provided here or you can remove the code from here and might need to make slight adjustments to the script you use (_don't forget to update the event that should get triggered to the one you use_).

Add this to your items.lua:
```lua
["printerdocument"] = {["name"] = "printerdocument", ["label"] = "Document", ["weight"] = 500, ["type"] = "item", ["image"] = "printerdocument.png", ["unique"] = true,     ["useable"] = true, ["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "A nice document"},
["printer"] = {["name"] = "printer", ["label"] = "Printer", ["weight"] = 5000, ["type"] = "item", ["image"] = "printer1.png", ["unique"] = true,     ["useable"] = true, ["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "Print a nice document"},
["printer2"] = {["name"] = "printer2", ["label"] = "Printer", ["weight"] = 5000, ["type"] = "item", ["image"] = "printer2.png", ["unique"] = true,     ["useable"] = true, ["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "Print a nice document"},
["printer3"] = {["name"] = "printer3", ["label"] = "Printer", ["weight"] = 5000, ["type"] = "item", ["image"] = "printer3.png", ["unique"] = true,     ["useable"] = true, ["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "Print a nice document"},
["printer4"] = {["name"] = "printer4", ["label"] = "Printer", ["weight"] = 5000, ["type"] = "item", ["image"] = "printer4.png", ["unique"] = true,     ["useable"] = true, ["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "Print a nice document"},
["photocopier"] = {["name"] = "printer5", ["label"] = "Photocopier", ["weight"] = 5000, ["type"] = "item", ["image"] = "photocopier.png", ["unique"] = true,     ["useable"] = true, ["shouldClose"] = true,   ["combinable"] = nil,   ["description"] = "Make a lot of copies"},
```

### Credit

[QBCore Framework - qb-printer](https://github.com/qbcore-framework/qb-printer)
We've modified this script to work with placeables and removed the dependency on QB framework.
