### 0.5.4 (2024/04/19)

#### Features

* [#69](https://github.com/ruby-grape/grape-swagger-entity/pull/67): Add support for minimum and maximum - [@storey](https://github.com/storey).

#### Fixes

* [#67](https://github.com/ruby-grape/grape-swagger-entity/pull/67): Various build updates - [@mscrivo](https://github.com/mscrivo).
* [#68](https://github.com/ruby-grape/grape-swagger-entity/pull/68): Properly render `example` for array exposure done using another entity - [@magni-](https://github.com/magni-).

### 0.5.3 (2024/02/02)

#### Features

* [#64](https://github.com/ruby-grape/grape-swagger-entity/pull/64): Pass extension documentation into schema - [@numbata](https://github.com/numbata).

#### Fixes

* [#66](https://github.com/ruby-grape/grape-swagger-entity/pull/66): Fix danger GHA - [@mscrivo](https://github.com/mscrivo).

### 0.5.2 (2023/07/07)

#### Fixes

* [#60](https://github.com/ruby-grape/grape-swagger-entity/pull/60): Examples on arrays should be directly on the property, not on the item - [@collinsauve](https://github.com/collinsauve).
* [#61](https://github.com/ruby-grape/grape-swagger-entity/pull/61): Migrate from Travis to GHA for CI - [@mscrivo](https://github.com/mscrivo).

### 0.5.1 (2020/06/30)

#### Features

* [#50](https://github.com/ruby-grape/grape-swagger-entity/pull/50): Features/inheritance and discriminator - [@MaximeRDY](https://github.com/MaximeRDY).

### 0.4.0 (2020/05/30)

#### Features

* [#49](https://github.com/ruby-grape/grape-swagger-entity/pull/49): Bumped minimal required version of grape-swagger to 1.0.0 - [@Bugagazavr](https://github.com/Bugagazavr).
* [#48](https://github.com/ruby-grape/grape-swagger-entity/pull/48): Add support for extensions - [@MaximeRDY](https://github.com/MaximeRDY).

#### Fixes

* [#46](https://github.com/ruby-grape/grape-swagger-entity/pull/46): Fixed issue where a boolean example value of false would not display in swagger file - [@drewnichols](https://github.com/drewnichols).

### 0.3.4 (2020/01/09)

#### Features

* [#40](https://github.com/ruby-grape/grape-swagger-entity/pull/40): Add support for minLength and maxLength - [@fotos](https://github.com/fotos).

### 0.3.3 (2019/02/22)

#### Features

* [#39](https://github.com/ruby-grape/grape-swagger-entity/pull/39): Fix to avoid conflict with polymorphic model - [@kinoppyd](https://github.com/kinoppyd).

### 0.3.2 (2019/01/15)

#### Features

* [#38](https://github.com/ruby-grape/grape-swagger-entity/pull/38): Added support for hidden option for documentation - [@vitoravelino](https://github.com/vitoravelino).

### 0.3.1 (2018/11/26)

#### Features

* [#37](https://github.com/ruby-grape/grape-swagger-entity/pull/37): Add support for minItems, maxItems and uniqueItems - [@fotos](https://github.com/fotos).

### 0.3.0 (2018/08/22)

#### Features

* [#35](https://github.com/ruby-grape/grape-swagger-entity/pull/35): Support for required attributes - [@Bugagazavr](https://github.com/Bugagazavr).

### 0.2.5 (2018/04/26)

#### Features

* [#33](https://github.com/ruby-grape/grape-swagger-entity/pull/33): Update parser to respect merge option for entities - [@b-boogaard](https://github.com/b-boogaard).

### 0.2.4 (2018/04/03)

#### Fixes

* [#32](https://github.com/ruby-grape/grape-swagger-entity/pull/32): Fix issue with read_only fields - [@mcfilib](https://github.com/mcfilib).

### 0.2.3 (2017/11/19)

#### Fixes

* [#30](https://github.com/ruby-grape/grape-swagger-entity/pull/30): Fix nested exposures with an alias - [@Kukunin](https://github.com/Kukunin).
* [#31](https://github.com/ruby-grape/grape-swagger-entity/pull/31): Respect `required: true` for nested attributes as well - [@Kukunin](https://github.com/Kukunin).

### 0.2.2 (2017/11/3)

#### Features

* [#27](https://github.com/ruby-grape/grape-swagger-entity/pull/27): Add support for attribute examples - [@Kukunin](https://github.com/Kukunin).

### 0.2.1 (2017/07/05)

#### Features

* [#26](https://github.com/ruby-grape/grape-swagger-entity/pull/26): Add support for read only field - [@FChaack](https://github.com/FChaack).

### 0.2.0 (2017/03/02)

#### Features

* [#22](https://github.com/ruby-grape/grape-swagger-entity/pull/22): Nested exposures - [@Bugagazavr](https://github.com/Bugagazavr).

### 0.1.6 (2017/02/03)

#### Features

* [#21](https://github.com/ruby-grape/grape-swagger-entity/pull/21): Adds support for own format - [@LeFnord](https://github.com/LeFnord).
* [#19](https://github.com/ruby-grape/grape-swagger-entity/pull/19): Adds support for default value - [@LeFnord](https://github.com/LeFnord).

### 0.1.5 (2016/11/21)

#### Features

* [#11](https://github.com/ruby-grape/grape-swagger-entity/pull/11): Use an automated PR linter, [danger.systems](http://danger.systems) - [@Bugagazavr](https://github.com/Bugagazavr).
* [#12](https://github.com/ruby-grape/grape-swagger-entity/pull/12): Allow parsing Entity with no endpoint - [@lordnibbler](https://github.com/lordnibbler).

#### Fixes

* [#8](https://github.com/ruby-grape/grape-swagger-entity/pull/8): Generate enum property if values key is passed in documentation - [@lordnibbler](https://github.com/lordnibbler).
* [#15](https://github.com/ruby-grape/grape-swagger-entity/pull/15): Support grape entity 0.6.x and later - [@Bugagazavr](https://github.com/Bugagazavr).

### 0.1.4 (2016/06/07)

#### Fixes

* [#7](https://github.com/ruby-grape/grape-swagger-entity/pull/7): Fixed array support for primitive types - [@Bugagazavr](https://github.com/Bugagazavr).
