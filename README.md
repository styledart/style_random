# Style Random

Random string generator with easy syntax and many complex options. Specify random template by character classes, define
length, order by classes, add conditions like starting with, ending with or duplication.

# Features

The random code generator that can be used for many needs is created with a single template. This template is parsed at
the beginning and generates random codes suitable for all conditions.

style_random is basically designed to customize random codes such as **data identifier**, **OTP**, **2FA**, **short
link** in the [style_dart](https://pub.dev/packages/style_dart) backend framework.

In addition, when we create the customized protocol in the web socket implementation, an additional small security
measure is aimed by verifying that the random message identifiers created by the client or received from the server are
created with the same **secret template**.

# Getting started

## Define Template

```dart
void main() {
  final generator = RandomGenerator("/l(5)A{-}/l(10)[#a]/e(#)/s({AEIOU})");
}
```

### What does it mean?

**In order;**

- 5 capital letters.
- 1 `-`
- 10 lowercase letters or numbers. (unordered)

**With Conditions;**

- Must start with a capital vowel
- Must end with a number

## Generate

```dart
void main() {
  final generator = RandomGenerator("/l(5)A{-}/l(10)[#a]/e(#)/s({AEIOU})");
  gen.generateString(); // x6
}
```

### Get results:

```text
URTYU-o92j72h484
AKOFK-37nj239564
EXMNO-73r2621302
UFKTJ-578u2lpo83
OFKIG-54o75p7730
EKXTQ-2lydl02b39
```

## Syntax

![](https://github.com/Mehmetyaz/style_random/blob/master/documentation/description.png)

We can start by explaining the numbers;

1) The things that make up a template are **expressions** and **options**.<br>
   Expressions are **character classes**, **character groups**, or **static characters**. These will be explained
   below. <br>

> `a [A#] {-}` <br><br>
> `a` lowercase letters<br>
> `[A#]` uppercase letters or numbers<br>
> `{-}` just `-`

2) The options at the end of the template affect the entire template. So we can call them **global options**.

> `<option><class>` this option only effect the class.<br>
> `<class1><class2><option>` and this option effect all template.

All options start with `/<option-name>`.<br>
In addition, options can take parameters such as `/<option-name>(<param1>,<param2>)`.

> `/l(10) a` for example `l` is the length option and when given to a character class it determines how many instances of that class will be produced. <br>
> `a # /l(15)` Similarly, it determines the length of the random value produced when given as a global option.

3) We can group character classes instead of one character class. The difference between grouping and regular typing is
   order. While it is sequential in normal writing, it randomly selects from among the group.

> `a [A#] {-}` <br>
> This statement produces a String with `a` , `[A#]` and `-` in order.<br>
> But the expression `[A#]` selects out of order in itself.

In the example below we can see this

```dart
void main() {
  var gen = RandomGenerator("/l(5)a /l(5)[A#] {-}");
  print(gen.generateString()); // x6
}
```

All outs ordered by `a`(lower letters) -> `[A#]`(group) -> `-`(static) <br>
But `A`(capital letters) and `#`(numbers) are mixed-order within themselves.

```text
jrloh68GXB-
kycmrZVR28-
hxeqaV24XO-
qefqmM16WK-
odpbuB7O7I-
yonidUBXUC-
```

# Usage

## Character classes

`.` any character. *(ASCII 33-126)* <br>  
`#` any number from 0 to 9. *9 include* <br>  
`*` any letter. *(ASCII 65-90 and 97-122)* <br>  
`l` lover case letters. *(ASCII 65-90)* <br>  
`L` upper case letters. *(ASCII 97-122)* <br>  
`s` any specific character *(ASCII 33-47, 58-64, 91-96, 123-126)* <br>  
`w` any specific character exclude url specific characters

### Group

`[<cl><cl>]` character class group. No sorting is done within the group.

`[a #]`  lower case letters or numbers

### Static Expression

Static characters are expressed with `{}`. Static expressions instantiate the contents as they are.

E.g. `{-}` , `{42}` , `{xyz}`

## Options

### `/l()` Length

The length option can be added anywhere. It determines the length of that expression when added to an expression, and
the length of the entire expression when added to global options.<br>
The length option can take a fixed number or a range.

#### Fixed

When a constant number like `/l(<n>)` is given, exactly `n` times produced.

#### Range

The length can be defined within a certain range.

If a range is given as a length, the generator checks the parent-child lengths. If it is impossible, it will throw an
error when `RandomGenerator` is defined.

This impossibility arises when the **maximum** value of the child is less than the **minimum** set by the parent (for
example, global `/l()`) for that child, etc.

There are 3 ways of range definition:

`/l(<min>-<max>)` minimum and maximum are defined.<br>
`/l(-<max>)` maximum is defined. If there is no minimum set by parent for this expression, the minimum can be 0. So from
this expression it may not be created at all. <br>
`/l(<min>-)` minimum is defined, maximum is infinity. The length must be restricted by the parent when this expression
is used. Otherwise, it will throw an error with the message "max unbounded".

If the range is used as the length, the generator randomly determines the lengths in these intervals when it is built.

The length of static expressions is always the length of the String inside.

```text
{-}      : auto add /l(1)
{mehmet} : auto add /l(6)
```

The Length option automatically determines the length of expressions without a length specified by looking at the child
parent relationships.

All results in the example below conform to the same template

```text
1. exp |      2.exp      | 3. exp | global opts
     a     /l(5)   [A#]     {-}       /l(11)
/l(5)a     /l(5)   [A#]     {-}
/l(5)a     /l(1-10)[A#]     {-}       /l(11)
/l(5)a             [A#]     {-}       /l(11)
a        [/l(3)A/l(2)#]     {-}       /l(11)
```

### End options

End options specifies the conditions for the start or end(last index) of expressions.

These end expressions are defined as `/option-name(classes or characters)`.

It can take more than one parameter. Character class names must be direct, and specific characters must inside of `{}`.
Parameters are separated by commas.

For example:

``/s(a,{-},{@5c}) .`` any character (ASCII 33-126) **BUT** **must start with**;

- `a` lower case letters<br>
  OR
- `{-}` the character of `-`<br>
  OR
- `{@5c}` characters of "@" or "5" or "c"

There are 4 types of end options.

##### `/s(<cl>|<char>)` Starts with

##### `/e(<cl>|<char>)` Ends with

##### `/<(<cl>|<char>)` Not start with

##### `/>(<cl>|<char>)` Not end with

> If you are using it for security purposes (for example, to generate a key), preventing(or to reduce) duplication or templates whose random values are similar to each other will NOT make your key more secure. It makes it more INSECURE.

#### Impossibility

While the template is being built, it is checked whether this condition is possible in most cases.

E.g. `/s(a) #` in the expression, generation with the condition is impossible. Because the condition is to create an
instance from class `#`, starting from class `a`. But any `#` does not contain any `a`.

Many possibilities are reviewed and if there is an impossibility, an error is thrown during the build. Loops are limited
to the square of the length to avoid endless loops due to missed debugging.

An error is thrown when these conditions conflict. If the parent has the same condition, the child is not accepted and
gives an error.

#### End Options Examples

`/s(#)/e(#)./l(20)` 20 any character. It must start with a number and end with a number.

`/s(#)/>(s)./l(20)`  20 any character. It must start with a number and not end with a specific characters.

## On Generate Length

If the range is used as the length, the generator randomly determines the lengths in these intervals when it is built.

This means that all results will be of the same length. But if you want the length to be re-selected for each instance (
with some performance degradation), then onGenerateLength: true should be.

```dart
void main() {
  var gen = RandomGenerator(
      "/l(1-9)# /l(1-9)a /l(10)",
      onGenerateLength: true
  );
}
```

In this example, numbers of length 1-9(random length in this range) and lowercase letters of length 1-9 are produced,
orderly.

If we want these lengths to change with each election, the result may be like this:

```text
              #  a
1402joprny    4  6
149375894j    9  1
1951222jid    7  3
045325921b    9  1
62275783mz    8  2
883267zryq    6  4
```

if `onGenerateLength: false` :

```text
             #  a
0050lpzaeb   4  6  // in the first instance the lengths were determined
3540ozjutp   4  6
4886zraewb   4  6
5013hcuovm   4  6
6461wcwdkd   4  6
2639wjysim   4  6
```

## Custom Random Delegate

Define custom random

```dart
class CustomRandom extends RandomDelegate {
  CustomRandom() : super();

  @override
  int nextInt(int max) {
    return 10;
  }
}
```

Use

```dart
void main() {
  var gen = RandomGenerator(
      "a[/l(3)A/l(2)#]{-}/l(11)",
      randomDelegate: CustomRandom()
  );
}
```

## Sample templates


#### Verification Code ``/l(3)# {-} /l(3)#``
```text
880-282
208-235
239-205
956-849
206-311
745-154
```

#### Short link

With url available specific characters : ``[*#w]/l(30)``

```text
))T(s-U8IfA6J4((b699l((c8cR34t
4w49!_1R3i'-.((*tvs!-Q7IdG1VtC
l61Y27.20_7*37'3if9Rnsn85g0wAu
!L1X!x4-1')!c8G(_U0__6R738qxhI
4g'X'6uUT-L..49T_*n_U'17y*60Vv
5-Q7LEA__6-6O25r36)1giH(4(.u78
```

For without specific characters: `[*#]/l(30)`



#### Suggest Password ``./l(16)``
```text
j+kKM]DDM"ne/2<>
(I+WHx7k@^kd^Xg^
Bd49/`>VM:jTr"yS
iyOQHVv]yinU7`%A
XQyS$o&-_62;0`2_
^[@/A#(X`If5+((M
```

#### Firebase Document ID `[*#]/l(20)`

````text
gQ9gaPh4e2J31U1CxedB
t09R5h053T19NG0bh2uK
W65r2UP099IDux645l8A
Pw601wg6Tq7kb63BN36O
f9n50Y4504B93D6LNjNV
C65Gn41MMLX59Wl326p9
````

#### Cool Code :) `{S} ## {-} /l(4)A {-} /l(4)#`
In codes such as appointment code, order code (even if it has no real meaning), it may be necessary to pretend that the code has a certain meaning.

```text
S45-FGJJ-5453
S77-IRTY-5725
S21-SLGB-9247
S56-NBKN-3393
S88-DAEB-6465
S31-QNJO-1611
```

#### Phone number: `{+90 5}##{ }###{ }##{ }##`
These numbers generated randomly!
![](https://github.com/styledart/style_random/blob/master/documentation/phones.png)


[//]: # (TODO: Add more example)

## Features to be added

- include - exclude options for character classes
- Duplication option: limit duplications , consecutive-duplications.
- Range option for `#`.
- Template matches. Checking the compatibility of the given samples with the template. For secret templates.
- Encoding-decoding with JSON.(toJson,fromJson)
- Random template generation. It can be used to generate a template as random.
- Tutorial - Demo web application like https://regexr.com/