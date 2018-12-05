# -- MODULES

module Blog

    # -- OPERATIONS

    def show_section(
        context : HTTP::Server::Context,
        section_id : Int32
        )

        session = Session.new( context );

        session.path = context.request.path;
        session.store( context );

        section_array = get_section_array();

        if ( section_id <= 0 )

            section_id = section_array[ 0 ].id;
        end

        section = get_section_by_id( section_id );

        if ( section )

            article_array = get_article_array_by_section_id( section_id );
            inflate_article_array( article_array );

            section.image_index = section_id % 20;

            render( "src/VIEW/show_section_view.ecr", "src/VIEW/show_page_view.ecr" );
        end
    end
end
