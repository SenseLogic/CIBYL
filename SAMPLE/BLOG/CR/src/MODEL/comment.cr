# -- MODULES

module Blog

    # -- TYPES

    class Comment

        # -- ATTRIBUTES

        property \
            id : Int32,
            article_id : Int32,
            user_id : Int32,
            text : String,
            date_time : Time,
            article : Article | Nil,
            user : User | Nil;

        # -- CONSTRUCTORS

        def initialize(
            @id = 0,
            @article_id = 0,
            @user_id = 0,
            @text = 0,
            @date_time = Time.utc( 1, 1, 1, 0, 0, 0 ),
            @article = nil,
            @user = nil
            ) : Void

        end
    end

    # -- FUNCTIONS

    def get_comment(
        result_set : DB::ResultSet
        ) : Comment

        return Comment.new(
            result_set.read( Int32 ),
            result_set.read( Int32 ),
            result_set.read( Int32 ),
            result_set.read( String ),
            result_set.read( Time )
            );
    end

    # ~~

    def inflate_comment(
        comment : Comment
        ) : Void

        comment.article = get_article_by_id( comment.article_id );
        comment.user = get_user_by_id( comment.user_id );
    end

    # ~~

    def inflate_comment_array(
        comment_array : Array( Comment )
        ) : Void

        comment_array.each \
            do | comment |

                inflate_comment( comment );
            end
    end

    # ~~

    def get_comment_array(
        ) : Array( Comment )

        comment_array = Array( Comment ).new();

        database.query_each "select * from COMMENT order by DateTime DESC" \
            do | result_set |

                comment_array.push( get_comment( result_set ) );
            end

        return comment_array;
    end

    # ~~

    def get_comment_by_id(
        id : Int32
        ) : Comment | Nil

        database.query_each "select * from COMMENT where Id = ?", id \
            do | result_set |

                return get_comment( result_set );
            end

        return nil;
    end

    # ~~

    def get_comment_array_by_article_id(
        article_id : Int32
        ) : Array( Comment )

        comment_array = Array( Comment ).new();

        database.query_each "select * from COMMENT where ArticleId = ? order by DateTime DESC", article_id \
            do | result_set |

                comment_array.push( get_comment( result_set ) );
            end

        return comment_array;
    end

    # ~~

    def change_comment(
        id : Int32,
        article_id : Int32,
        user_id : Int32,
        text : String,
        date_time : String
        ) : Void

        database.exec(
            "update COMMENT set Id = ?, ArticleId = ?, UserId = ?, Text = ?, DateTime = ? where Id = ?",
            id,
            article_id,
            user_id,
            text,
            date_time,
            id
            );
    end

    # ~~

    def add_comment(
        article_id : Int32,
        user_id : Int32,
        text : String
        ) : Int32

        database.exec(
            "insert into COMMENT ( ArticleId, UserId, Text, DateTime ) values ( ?, ?, ?, NOW() )",
            article_id,
            user_id,
            text
            );

        return get_last_insert_id();
    end

    # ~~

    def remove_comment(
        id : Int32
        ) : Void

        database.exec(
            "delete from COMMENT where Id = ?",
            id
            );
    end
end
