<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage



## Character classes
`.` any character. *(ASCII 33-126)* <br>
`#` any number from 0 to 9. *9 include* <br>
`*` any letter. *(ASCII 65-90 and 97-122)* <br>
`l` lover case letters. *(ASCII 65-90)* <br>
`L` upper case letters. *(ASCII 65-90)* <br>
`s` any specific character *(ASCII 33-47, 58-64, 91-96, 123-126)* <br>
`w` any specific character exclude url specific characters

## Expressions

> These **variables** will be used in the following expressions; <br>
> `<ch>` is any character <br>
> `<cl>` is character class <br>
> `<n>` , `<m>` are numbers <br>

`{<ch>}` : static characters

> E.g. `{-}` , out : `-` <br>
> E.g. `{18i-6}` , out : `18i-6` <br>

`[<cl><cl>]` : any member of any defined classes. Not sorted

> E.g. `[#]` , out : `6` (random selected) <br>
> E.g. `[l#]` , out : `4` or  `a`. (random selected from `l` or `#`) <br>
> E.g. `[Ls#]` , out : `~` or `B` or `5`. (random selected from `L` or `s` or `#`) <br>

`<cl><n>`  : n selections from `<cl>`

> E.g. `#6` , out : `168304` <br>
> E.g. `[l2#4]` , out : `1a56e7` . *2 of `l` , 4 of `#`* <br>

## Options

> If you are using it for security purposes (for example, to generate a key), preventing(or to reduce) duplication will NOT make your key more secure. It makes it more INSECURE.



`/d{<n>}` repeat max n <br>
`/u` unique - not duplicate <br>
`/l(<n>)` total len




`/n(<ch> or <cl>)[]` not start <br>
`/<()[]` start with <br>
`/>()[]` end with <br>


Random length <br>
`/r(<x?>-<y?>)=<name?>#`  : `/r(5-)#`, `/r(-10)var1=l`, `/r(0-30})s`

Variable <br>
`{operation}` : operation <br>
`$var` use variable

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
