#include <stdio.h>
#include <X11/XKBlib.h>

int main ()
{
    printf("lala");
    printf("%i", XkbOpenDisplay("lalafa",0,0,0,0,0));
    printf("fa\n");
}
