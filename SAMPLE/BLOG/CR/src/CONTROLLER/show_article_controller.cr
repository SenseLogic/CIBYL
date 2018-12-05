# -- MODULES

module Blog

    # -- OPERATIONS

    def show_article(
        context : HTTP::Server::Context,
        article_id : Int32
        )

        session = Session.new( context );

        session.path = context.request.path;
        session.store( context );

        article = get_article_by_id( article_id );

        if ( article )

            section = get_section_by_id( article.section_id );

            if ( section )

                section_array = get_section_array();
                comment_array = get_comment_array_by_article_id( article_id );

                article.image_index = article.id % 20;
                inflate_article( article );
                inflate_comment_array( comment_array );

                render( "src/VIEW/show_article_view.ecr", "src/VIEW/show_page_view.ecr" );
            end
        end
    end
end
