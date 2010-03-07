#include <iostream>
#include <m17n.h>

int main()
{
    MPlist *imlist, *elm;
    MSymbol utf8 = msymbol("utf8");
    M17N_INIT();
    imlist = mdatabase_list(msymbol("input-method"), Mnil, Mnil, Mnil);
    for (elm = imlist; elm && mplist_key(elm) != Mnil; elm = 
mplist_next(elm)) {
        MDatabase *mdb = (MDatabase *) mplist_value(elm);
        MSymbol *tag = mdatabase_tag(mdb);
        if (tag[1] != Mnil) {
            MInputMethod *im = minput_open_im(tag[1], tag[2], NULL);
            if (im) {
                std::cout << msymbol_name (im->language);
                std::cout << "-";
                std::cout << msymbol_name (im->name);
                std::cout << "\n";
            }
        }
    }
    M17N_FINI();
}
