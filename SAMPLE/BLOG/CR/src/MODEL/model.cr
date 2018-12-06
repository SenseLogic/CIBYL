# -- IMPORTS

require "./article.cr";
require "./comment.cr";
require "./section.cr";
require "./session.cr";
require "./subscriber.cr";
require "./user.cr";

# -- MODULES

module Blog

    # -- FUNCTIONS

    def get_last_insert_id(
        ) : Int32

        new_id = 0;

        database.query_each( "select last_insert_id()" ) \
            do | result_set |

                new_id = result_set.read( Int64 ).to_i32();
            end

        return new_id;
    end
end
