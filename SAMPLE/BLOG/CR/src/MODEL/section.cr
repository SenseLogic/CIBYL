# -- MODULES

module Blog

    # -- TYPES

    class Section

        # -- ATTRIBUTES

        property \
            id : Int32,
            number : Int32,
            name : String,
            text : String,
            image : String,
            image_index : Int32;

        # -- CONSTRUCTORS

        def initialize(
            @id = 0,
            @number = 0,
            @name = "",
            @text = "",
            @image = "",
            @image_index = 0
            ) : Void

        end
    end

    # -- FUNCTIONS

    def get_section(
        result_set : DB::ResultSet
        ) : Section

        return Section.new(
            result_set.read( Int32 ),
            result_set.read( Int32 ),
            result_set.read( String ),
            result_set.read( String ),
            result_set.read( String )
            );
    end

    # ~~

    def get_section_array(
        ) : Array( Section )

        section_array = Array( Section ).new();

        database.query_each "select * from SECTION order by Number asc" \
            do | result_set |

                section_array.push( get_section( result_set ) );
            end

        return section_array;
    end

    # ~~

    def get_section_by_id(
        id : Int32
        ) : Section | Nil

        database.query_each "select * from SECTION where Id = ?", id \
            do | result_set |

                return get_section( result_set );
            end

        return nil;
    end

    # ~~

    def change_section(
        id : Int32,
        number : Int32,
        name : String,
        text : String,
        image : String
        ) : Void

        database.exec(
            "update SECTION set Id = ?, Number = ?, Name = ?, Text = ?, Image = ? where Id = ?",
            id,
            number,
            name,
            text,
            image,
            id
            );
    end

    # ~~

    def add_section(
        number : Int32,
        name : String,
        text : String,
        image : String
        ) : Int32

        database.exec(
            "insert into SECTION ( Number, Name, Text, Image ) values ( ?, ?, ?, ? )",
            number,
            name,
            text,
            image
            );

        return get_last_insert_id();
    end

    # ~~

    def remove_section(
        id : Int32
        ) : Void

        database.exec(
            "delete from SECTION where Id = ?",
            id
            );
    end
end
