// Silly example script which makes the raplet background blue when you hover over it.
// Please remove it and replace it with something useful.
jQuery('div.wrapper').hover(
    function () { // mouseover
        jQuery(this).css('background-color', '#ddf');
    },
    function () { // mouseout
        jQuery(this).css('background-color', '#fff');
    }
);
