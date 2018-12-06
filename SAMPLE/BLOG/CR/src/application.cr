# -- IMPORTS

require "db";
require "ecr";
require "kemal";
require "kemal-session";
require "mysql";
require "./CONTROLLER/controller.cr";
require "./MODEL/model.cr";

# -- TYPES

class Application

    # -- IMPORTS

    include Blog;

    # -- ATTRIBUTES

    property \
        database : DB::Database;

    # -- CONSTRUCTORS

    def initialize(
        @database = DB.open( "mysql://root:root@localhost:3306/BLOG" )
        ) : Void

    end

    # -- OPERATIONS

    def run(
        ) : Void

        Kemal::Session.config \
            do | config |

                config.secret = "Top secret ;)";
            end

        get( "/" ) \
            do | context |

                show_section( context, 0 );
            end

        get( "/show_section/:section_id" ) \
            do | context |

                section_id = context.params.url[ "section_id" ];
                show_section( context, section_id.to_i32() );
            end

        get( "/show_article/:article_id" ) \
            do | context |

                article_id = context.params.url[ "article_id" ];
                show_article( context, article_id.to_i32() );
            end

        post( "/add_comment/:article_id" ) \
            do | context |

                article_id = context.params.url[ "article_id" ];
                add_comment( context, article_id.to_i32() );
            end

        post( "/add_subscriber" ) \
            do | context |

                add_subscriber( context );
            end

        post( "/connect_user" ) \
            do | context |

                connect_user( context );
            end

        post( "/disconnect_user" ) \
            do | context |

                disconnect_user( context );
            end

        Kemal.run() \
            do | configuration |

                configuration.server.not_nil!().bind_tcp( "0.0.0.0", 3000, reuse_port: true );
            end
    end
end

# -- STATEMENTS

application = Application.new();
application.run();
