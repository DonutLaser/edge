# edgelang
Programming language that doesn't get in your way

# Functions
Return type must be specified explicitly
```
func foo() void {

}
```

Function that do return something must do so
```
func foo() i32 {
    return 0 # Correct
}
```
```
func foo() i32 {
    # Error, function does not return anything even though it should
}
```

Multiple return values
```
func foo() (i32, str) [
    return 0, 'hello'
]
```

# Variables
Mutable variables
```
let intValue: i32 = 0
let floatValue: f32 = 0
let boolValue: bool = true
let stringValue: str = 'Hello'
let arrVariable: [i32, 5] = [] # In this case, must specify the size, by default all items will be initialized to 0
let arrVariable2: [i32] = [1, 2, 3] # In this case, don't have to specify the size as it is clear that the size is 3
let tupleVariable: (i32, str) = () # By default initialized to a tuple (0, '')
let tupleVariable2: () = (0, 'hello')
let tupleVariable3: (i32, str, bool) = () # Tuple can have more than 2 values
```

Immutable variables, must be immediatelly initialized. If array is immutable, that means you cannot add items to it or remove them
```
const intValue: i32 = 0
const floatValue: f32 = 0.0
const boolValue: bool = false
const stringValue: str = 'Hello'
const arrVariable: [i32, 5] = [] # By default all items will be initialized to 0
const arrVariable2: [i32] = [1, 2, 3]
```

Types can be inferred
```
const intValue = 0
const floatValue = 0.0
const boolValue = true
const stringValue = 'Hello' 
const arrVariable = [] # Error, unknown type and size
const arrVariable2 = [1, 2, 3] # No error, type and size is inferred
const tupleVariable = (0, 'hello')
```

# Types
- u8, u16, u32, u64 # Unsigned int
- i8, i16, i32, i64 # Signed int
- f32, f64 # Floats
- bool # Boolean
- str # String

# If
Parentheses are not required for the `if` conditions
```
if a < b {

} elif a > b {

} else {

}
```

Ternary operator
```
let smth = a < b ? 'less' : 'more'
```

Match statement
```
let a = 2
match a {
    1 => { ... },
    2, 3, 4 => { ... },
    5 => { ... },
    6 => { ... },
    else => unreachable
}
```

# Loops
Infinite loop
```
for {

}
```

Loop over array
```
const items = [1, 2, 3]
for items {
    print(it) # `it` refers to the current item
}
```

Loop over array with custom item name
```
const items = [1, 2, 3]
for item in items {
    print(item)
}
```

Get iteration index
```
const items = [1, 2, 3]
for item, index in items {
    print(index)
}
```

While loop
```
let i = 10;
for i > 0 {
    print(i)
    --i
}
```

Break statement
```
const items = [1, 2, 3]
for items {
    if it == 1 {
        break
    }
}
```

Continue statement
```
const items = [1, 2, 3, 4]
for items {
    if it % 2 == 0 {
        continue
    }
}
```

# Enums
Default underlying type of enum is u32 and values start from 0 and increase by 1
```
enum State {
    Menu, # implicit value 0
    Gameplay, # implicit value 1
    GameOver, # implicit value 2
}
```

Explicitly speicify enum values
```
enum State {
    Menu = 1,
    Gameplay = 2,
    GameOver = 4
}
```

Speicifying the underlying type of enum values. Some types (for example, `str`), require you to specify the underlying value for each value of the enum
```
enum State: str {
    Menu = 'menu',
    Gameplay = 'gameplay',
    GameOver = 'gameover',
}
```

# Structs
Creating a struct. By default, struct members are public, but can be made private by prepending `_` underscore to the name
```
struct Point {
    x: i32
    y: i32
    _data: str # Private member
}
```

Using a struct
```
let new_point = Point{ x: 0, y: 0 }
print(new_point.x)
print(new_point.y)
```

Struct can have methods. Methods are public by default, just as with member variables, prepend `_` underscore to the name to make the m private
```
struct Rect {
    x: i32
    y: i32
    width: u32
    height: u32

    func area() u32 {
        return .width * .height
    }

    func _right() i32 {
        return .x + .width
    }
}
```

Struct constructor. Compiler implicitly creates a constructor with as many parameters as there are public variables.
```
struct Point {
    x: i32
    y: i32

    # Special function, constructor, cannot be private
    init() {
        .x = 0
        .y = 0
    }
}
```

When there's a need to create a class, you use structs.  
Structs do not have inheritance.  

# Errors
Function that throws a generic error.
```
# The function that doesn't normally return anything, but it might return an error
func main() void throws {
}
```

Handling function that throws an error. `try` keyword handles the error. If an error was returned, it will propagate the error, otherwise it will let the function to continue working.
```
func main() void throws {
    var file = try read_file(...)
}
```

Using `catch` to do something with the error
```
func main() void throws {
    var file = try read_file(...) catch {
        print(err) # `err` is built in keyword
    }
}
```


# Tuples
Destructuring a tuple
```
let t = (0, 'vidmantas', true)
let index, name, success = t
```

Accessing individual values of the tuple
```
let t = (5, 'vidmantas', false)
print(t.0)
print(t.1)
print(t.2)
```
