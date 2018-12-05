# -- MODULES

module Blog

    # -- TYPES

    class Subscriber

        # -- ATTRIBUTES

        property \
            id : Int32,
            email : String;

        # -- CONSTRUCTORS

        def initialize(
            @id = 0,
            @email = ""
            ) : Void

        end
    end

    # -- FUNCTIONS

    def get_subscriber(
        result_set : DB::ResultSet
        ) : Subscriber

        return Subscriber.new(
            result_set.read( Int32 ),
            result_set.read( String )
            );
    end

    # ~~

    def get_subscriber_array(
        ) : Array( Subscriber )

        subscriber_array = Array( Subscriber ).new();

        database.query_each "select * from SUBSCRIBER order by Email asc" \
            do | result_set |

                subscriber_array.push( get_subscriber( result_set ) );
            end

        return subscriber_array;
    end

    # ~~

    def get_subscriber_by_id(
        id : Int32
        ) : Subscriber | Nil

        database.query_each "select * from SUBSCRIBER where Id = ?", id \
            do | result_set |

                return get_subscriber( result_set );
            end

        return nil;
    end

    # ~~

    def change_subscriber(
        id : Int32,
        email : String
        ) : Void

        database.exec(
            "update SUBSCRIBER set Id = ?, Email = ? where Id = ?",
            id,
            email,
            id
            );
    end

    # ~~

    def add_subscriber(
        email : String
        ) : Int32

        database.exec(
            "insert into SUBSCRIBER ( Email ) values ( ? )",
            email
            );

        return get_last_insert_id();
    end

    # ~~

    def remove_subscriber(
        id : Int32
        ) : Void

        database.exec(
            "delete from SUBSCRIBER where Id = ?",
            id
            );
    end
end
