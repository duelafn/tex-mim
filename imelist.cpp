/*

  Code originally posted by David david at plm11.pl to SCIM mailing list
  on Mon Oct 4 23:54:46 UTC 2004

  http://lists.freedesktop.org/archives/scim/2004-October/001024.html

  ...

  I guess you noticed the words "correct *.mim file". If you make a
  mistake, SCIM will not load your new input table. How will you know,
  whether it is some misconfiguration or your error? How you can check
  whether your IME can be loaded?

  I did not know that either. To find out I made a copy of a few lines from
  James Su code (scim_m17n_imengine.cpp) responsible for loading m17lib
  IMEs. Please copy these lines to a file , let's call it "imelist.cpp".

  Compile it with "g++ -lm17n -o imelist imelist.cpp".

  Now, if you run the program "imelist", it will list all the imes that
  SCIM will load. If you make a mistake in your table, it will not get
  listed, so you know you have to correct it.


*/

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
