<?php
/**
 *  * Register our sidebars and widgetized areas.
 *   *
 *    */

    /*WIDGET_DISABLE_COMMENT
    function iu_widgets_init() {
        $iunames = array(_IU_WIDGET_NAMES_);
        foreach($iunames as $iuname){
            register_sidebar( array(
                                    'name' => $iuname,
                                    'id' => str_replace(' ', '',$iuname),
                                    'before_widget' => '<div class="WPWidget">',
                                    'after_widget' => '</div>',
                                    'before_title' => '<h2 class="WPWidgetTitle">',
                                    'after_title' => '</h2>',
                                    ) );
        }
    }

    add_action( 'widgets_init', 'iu_widgets_init' );

     WIDGET_DISABLE_COMMENT*/
    register_nav_menu('default', 'default');
?>