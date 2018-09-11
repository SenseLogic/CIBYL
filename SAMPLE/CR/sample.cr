# Recursive Fibonacci function

def fibonacci(
    n : Int32
    )
    if ( n <= 1 )
        return n;
    else
        return fibonacci( n - 1 ) + fibonacci( n - 2 );
    end
end

puts fibonacci( 8 );

