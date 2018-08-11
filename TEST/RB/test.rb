# -- MODULES

module CIBYL
    # -- TYPES

    enum COLOR
        # -- CONSTANTS

        Red
        Green
        Blue

        # -- INQUIRIES

        def red?
            return self == Red;
        end
    end

    # ~~

    abstract struct ABSTRACT
    end

    # ~~

    struct POINT
        # -- ATTRIBUTES

        property name, age;

        # -- CONSTRUCTORS

        def initialize(
            @name : String,
            @age : Int32
            )
        end

        # -- OPERATIONS

        protected def print(
            )
            puts "#{age} - #{name}";
        end
    end

    # ~~

    class TEST
        # -- OPERATIONS

        def test_if(
            count : Int
            ) : Int
            if ( count <= 1 )
                return 10;
            end

            if ( count <= 1 )
                return 10;
            else
                return 20;
            end

            if ( count <= 1 )
                return 10;
            elsif ( count <= 2 )
                return 20;
            else
                return 30;
            end
        end

        # ~~

        def test_unless(
            count : Int
            ) : Int
            unless ( count > 1 )
                return 10;
            end

            unless ( count > 1 )
                return 10;
            else
                return 20;
            end
        end

        # ~~

        def test_while(
            count : Int
            )
            index = 0;

            while ( index < count )
                index = index + 1;
            end
        end

        # ~~

        def test_until(
            count : Int
            )
            index = 0;

            until ( index >= count )
                index = index + 1;
            end
        end

        # ~~

        def test_case(
            count : Int
            )
            case ( count )
                when 1
                    return 10;
            end

            case ( count )
                when 1
                    return 10;
                when 2
                    return 20;
            end

            case ( count )
                when 1
                    return 10;
                when 2
                    return 20;
                else
                    return 30;
            end
        end

        # ~~

        def test_begin
            begin
                result = 1;
            rescue
                result = 2;
            else
                result = 3;
            ensure
                result = 4;
            end
        end

        # ~~

        def test_rescue
            result = 1;
        rescue
            result = 2;
        else
            result = 3;
        ensure
            result = 4;
        end

        # ~~

        def test_each
            "0123456789".each_char \
                do |character|
                    print( character );
                end

            print( '\n' );

            [
                {1, "A"},
                {2, "B"}
            ].each \
                do |key, value|
                    puts( "#{@key} : #{@value}" );
                end
        end
    end
end

# -- STATEMENTS

require "http/server";

server = HTTP::Server.new \
    do |context|
        context.response.content_type = "text/plain";
        context.response.print( "Hello world! The time is #{Time.now}" );
    end

address = server.bind_tcp( 8080 );
puts( "Listening on http://#{address}" );
server.listen();

