greeting() = "Hello, Julia!"

if abspath(PROGRAM_FILE) == @__FILE__
    println(greeting())
end
