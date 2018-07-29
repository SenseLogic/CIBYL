# Recursive Fibonacci function

def fibonacci(
    n : Int32
    )
    if ( n <= 1 )
        1
    else
        fibonacci( n - 1 ) + fibonacci( n - 2 )
    end
end

puts fibonacci( 5 )

