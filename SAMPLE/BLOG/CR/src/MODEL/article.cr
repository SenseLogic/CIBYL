# -- MODULES

module Blog

    # -- TYPES

    class Article

        # -- ATTRIBUTES

        property \
            id : Int32,
            section_id : Int32,
            user_id : Int32,
            title : String,
            text : String,
            image : String,
            date : Time,
            section : Section | Nil,
            user : User | Nil,
            image_index : Int32;

        # -- CONSTRUCTORS

        def initialize(
            @id = 0,
            @section_id = 0,
            @user_id = 0,
            @title = "",
            @text = "",
            @image = "",
            @date = Time.utc( 1, 1, 1, 0, 0, 0 ),
            @section = nil,
            @user = nil,
            @image_index = 0
            ) : Void

        end
    end

    # -- FUNCTIONS

    def get_article(
        result_set : DB::ResultSet
        ) : Article

        return Article.new(
            result_set.read( Int32 ),
            result_set.read( Int32 ),
            result_set.read( Int32 ),
            result_set.read( String ),
            result_set.read( String ),
            result_set.read( String ),
            result_set.read( Time )
            );
    end

    # ~~

    def inflate_article(
        article : Article
        ) : Void

        article.section = get_section_by_id( article.section_id );
        article.user = get_user_by_id( article.user_id );
    end

    # ~~

    def inflate_article_array(
        article_array : Array( Article )
        ) : Void

        article_array.each \
            do | article |

                inflate_article( article );
            end
    end

    # ~~

    def get_article_array(
        ) : Array( Article )

        article_array = Array( Article ).new();

        database.query_each "select * from ARTICLE order by Date DESC" \
            do | result_set |

                article_array.push( get_article( result_set ) );
            end

        return article_array;
    end

    # ~~

    def get_article_by_id(
        id : Int32
        ) : Article | Nil

        database.query_each "select * from ARTICLE where Id = ?", id \
            do | result_set |

                return get_article( result_set );
            end

        return nil;
    end

    # ~~

    def get_article_array_by_section_id(
        section_id : Int32
        ) : Array( Article )

        article_array = Array( Article ).new();

        database.query_each "select * from ARTICLE where SectionId = ? order by Date DESC", section_id \
            do | result_set |

                article_array.push( get_article( result_set ) );
            end

        return article_array;
    end

    # ~~

    def change_article(
        id : Int32,
        title : String,
        text : String,
        image : String,
        date : String,
        section_id : Int32,
        user_id : Int32
        ) : Void

        database.exec(
            "update ARTICLE set Id = ?, SectionId = ?, UserId = ?, Title = ?, Text = ?, Image = ?, Date = ? where Id = ?",
            id,
            section_id,
            user_id,
            title,
            text,
            image,
            date,
            id
            );
    end

    # ~~

    def add_article(
        title : String,
        text : String,
        image : String,
        section_id : Int32,
        user_id : Int32
        ) : Int32

        database.exec(
            "insert into ARTICLE ( SectionId, UserId, Title, Text, Image, Date ) values ( ?, ?, ?, ?, ?, NOW() )",
            section_id,
            user_id,
            title,
            text,
            image
            );

        return get_last_insert_id();
    end

    # ~~

    def remove_article(
        id : Int32
        ) : Void

        database.exec(
            "delete from ARTICLE where Id = ?",
            id
            );
    end
end
