# -- MODULES

module Blog

    # -- TYPES

    class User

        # -- ATTRIBUTES

        property \
            id : Int32,
            email : String,
            pseudonym : String,
            password : String,
            is_administrator : Bool;

        # -- CONSTRUCTORS

        def initialize(
            @id = 0,
            @email = "",
            @pseudonym = "",
            @password = "",
            @is_administrator = false
            ) : Void

        end
    end

    # -- FUNCTIONS

    def get_user(
        result_set : DB::ResultSet
        ) : User

        return User.new(
            result_set.read( Int32 ),
            result_set.read( String ),
            result_set.read( String ),
            result_set.read( String ),
            result_set.read( Int8 ) ? true : false
            );
    end

    # ~~

    def get_user_array(
        ) : Array( User )

        user_array = Array( User ).new();

        database.query_each "select * from USER order by Email asc" \
            do | result_set |

                user_array.push( get_user( result_set ) );
            end

        return user_array;
    end

    # ~~

    def get_user_by_id(
        id : Int32
        ) : User | Nil

        database.query_each "select * from USER where Id = ?", id \
            do | result_set |

                return get_user( result_set );
            end

        return nil;
    end

    # ~~

    def get_user_by_pseudonym_and_password(
        pseudonym : String,
        password : String
        ) : User | Nil

        database.query_each "select * from USER where Pseudonym = ? and Password = ?", pseudonym, password \
            do | result_set |

                return get_user( result_set );
            end

        return nil;
    end

    # ~~

    def change_user(
        id : Int32,
        email : String,
        pseudonym : String,
        password : String,
        it_is_administrator : Bool
        ) : Void

        database.exec(
            "update USER set Id = ?, Email = ?, Pseudonym = ?, Password = ?, IsAdministrator = ? where Id = ?",
            id,
            email,
            pseudonym,
            password,
            it_is_administrator ? 1 : 0,
            id
            );
    end

    # ~~

    def add_user(
        email : String,
        pseudonym : String,
        password : String,
        it_is_administrator : Bool
        ) : Int32

        database.exec(
            "insert into USER ( Email, Pseudonym, Password, IsAdministrator ) values ( ?, ?, ?, ? )",
            email,
            pseudonym,
            password,
            it_is_administrator ? 1 : 0
            );

        return get_last_insert_id();
    end

    # ~~

    def remove_user(
        id : Int32
        ) : Void

        database.exec(
            "delete from USER where Id = ?",
            id
            );
    end
end
