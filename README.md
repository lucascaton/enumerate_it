# EnumerateIt - Ruby Enumerations

[![Build Status](https://travis-ci.org/lucascaton/enumerate_it.svg?branch=master)](https://travis-ci.org/lucascaton/enumerate_it)
[![Gem Version](https://badge.fury.io/rb/enumerate_it.svg)](https://rubygems.org/gems/enumerate_it)
[![Code Climate](https://codeclimate.com/github/lucascaton/enumerate_it/badges/gpa.svg)](https://codeclimate.com/github/lucascaton/enumerate_it)
[![Changelog](https://img.shields.io/badge/changelog--brightgreen.svg?style=flat)](https://github.com/lucascaton/enumerate_it/releases)

* **Author:** Cássio Marques
* **Maintainer:** Lucas Caton

## Description

Ok, I know there are a lot of different solutions to this problem. But none of
them solved my problem, so here's EnumerateIt. I needed to build a Rails
application around a legacy database and this database was filled with those
small, unchangeable tables used to create foreign key constraints everywhere.

### For example:

    Table "public.relationshipstatus"

      Column     |     Type      | Modifiers
    -------------+---------------+-----------
     code        | character(1)  | not null
     description | character(11) |

    Indexes:
      "relationshipstatus_pkey" PRIMARY KEY, btree (code)

    SELECT * FROM relationshipstatus;

    code   |  description
    -------+--------------
    1      | Single
    2      | Married
    3      | Widow
    4      | Divorced

And then I had things like a people table with a 'relationship_status' column
with a foreign key pointing to the relationshipstatus table.

While this is a good thing from the database normalization perspective,
managing this values in my tests was very hard. Doing database joins just to
get the description of some value was absurd. And, more than this, referencing
them in my code using magic numbers was terrible and meaningless: What does it
mean when we say that someone or something is '2'?

Enter EnumerateIt.

## Changelog

Changes are maintained under [Releases](https://github.com/lucascaton/enumerate_it/releases).

## Creating enumerations

Enumerations are created as classes and you should put them inside `app/enumerations` folder.

```ruby
class RelationshipStatus < EnumerateIt::Base
  associate_values(
    single:   [1, 'Single'],
    married:  [2, 'Married'],
    widow:    [3, 'Widow'],
    divorced: [4, 'Divorced']
  )
end
```

This will create some nice stuff:

*   Each enumeration's value will turn into a constant:

    ```ruby
    RelationshipStatus::SINGLE
    #=> 1

    RelationshipStatus::MARRIED
    #=> 2
    ```

*   You can retrieve a list with all the enumeration codes:

    ```ruby
    RelationshipStatus.list
    #=> [1, 2, 3, 4]
    ```

*   You can get an array of options, ready to use with the 'select',
    'select_tag', etc family of Rails helpers.

    ```ruby
    RelationshipStatus.to_a
    #=> [["Divorced", 4], ["Married", 2], ["Single", 1], ["Widow", 3]]
    ```

*   You can retrieve a list with values for a group of enumeration constants.

    ```ruby
    RelationshipStatus.values_for %w(MARRIED SINGLE)
    #=> [2, 1]
    ```

*   You can retrieve the value for a specific enumeration constant:

    ```ruby
    RelationshipStatus.value_for("MARRIED")
    #=> 2
    ```

*   You can retrieve the symbol used to declare a specific enumeration value:

    ```ruby
    RelationshipStatus.key_for(RelationshipStatus::MARRIED)
    #=> :married
    ```

*   You can iterate over the list of the enumeration's values:

    ```ruby
    RelationshipStatus.each_value { |value| ... }
    ```

*   You can iterate over the list of the enumeration's translations:

    ```ruby
    RelationshipStatus.each_translation { |translation| ... }
    ```

*   You can also retrieve all the translations of the enumeration:

    ```ruby
    RelationshipStatus.translations
    ```

*   You can ask for the enumeration's length:

    ```ruby
    RelationshipStatus.length
    #=> 4
    ```

*   You can manipulate the hash used to create the enumeration:

    ```ruby
    RelationshipStatus.enumeration
    #=> returns the exact hash used to define the enumeration
    ```

You can also create enumerations in the following ways:

*   Passing an array of symbols, so that the respective value for each symbol
    will be the stringified version of the symbol itself:

    ```ruby
    class RelationshipStatus < EnumerateIt::Base
      associate_values :married, :single
    end

    RelationshipStatus::MARRIED
    #=> "married"
    ```

*   Passing hashes where the value for each key/pair does not include a
    translation. In this case, the I18n feature will be used (more on this
    below):

    ```ruby
    class RelationshipStatus < EnumerateIt::Base
      associate_values married: 1, single: 2
    end
    ```

### Defining a default sort mode

When calling methods like `to_a`, `to_json` and `list`, the returned values
will be sorted using the translation for each one of the enumeration values.
If you want to overwrite the default sort mode, you can use the `sort_by` class
method.

```ruby
class RelationshipStatus < EnumerateIt::Base
  associate_values married: 1, single: 2

  sort_by :value
end
```

The `sort_by` methods accept one of the following values:

* `:translation`: The default behavior, will sort the returned values based on translations.
* `:value`: Will sort the returned values based on values.
* `:name`: Will sort the returned values based on the name of each enumeration option.
* `:none`: Will return values in order that was passed to associate_values call.

## Using enumerations

The cool part is that you can use these enumerations with any class, be it an
ActiveRecord instance or not.

```ruby
class Person
  extend EnumerateIt
  attr_accessor :relationship_status

  has_enumeration_for :relationship_status, with: RelationshipStatus
end
```

The `:with` option is not required. If you ommit it, EnumerateIt will try to
load an enumeration class based on the camelized attribute name.

This will create:

*   A humanized description for the values of the enumerated attribute:

    ```ruby
    p = Person.new
    p.relationship_status = RelationshipStatus::DIVORCED
    p.relationship_status_humanize
    #=> 'Divorced'
    ```

*   If you don't supply a humanized string to represent an option, EnumerateIt
    will use a 'humanized' version of the hash's key to humanize the
    attribute's value:

    ```ruby
    class RelationshipStatus < EnumerateIt::Base
      associate_values(
        married: 1,
        single: 2
      )
    end

    p = Person.new
    p.relationship_status = RelationshipStatus::MARRIED
    p.relationship_status_humanize
    #=> 'Married'
    ```

*   The associated enumerations can be retrieved with the 'enumerations' class
    method.

    ```ruby
    Person.enumerations[:relationship_status]
    #=> RelationshipStatus
    ```

*   If you pass the `:create_helpers` option as `true`, it will create a helper
    method for each enumeration option (this option defaults to false):

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus, create_helpers: true
    end

    p = Person.new
    p.relationship_status = RelationshipStatus::MARRIED

    p.married?
    #=> true

    p.divorced?
    #=> false
    ```

*   It's also possible to "namespace" the created helper methods, passing a
    hash to the `:create_helpers` option. This can be useful when two or more of
    the enumerations used share the same constants.

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus,
                                                create_helpers: { prefix: true }
    end

    p = Person.new
    p.relationship_status = RelationshipStatus::MARRIED

    p.relationship_status_married?
    #=> true

    p.relationship_status_divoced?
    #=> false
    ```

*   You can define polymorphic behavior for the enum values, so you can define
    a class for each of them:

    ```ruby
    class RelationshipStatus < EnumerateIt::Base
      associate_values :married, :single

      class Married
        def saturday_night
          "At home with the kids"
        end
      end

      class Single
        def saturday_night
          "Party Hard!"
        end
      end
    end

    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus,
                                                create_helpers: { polymorphic: true }
    end

    p = Person.new
    p.relationship_status = RelationshipStatus::MARRIED
    p.relationship_status_object.saturday_night
    #=> "At home with the kids"

    p.relationship_status = RelationshipStatus::SINGLE
    p.relationship_status_object.saturday_night
    #=> "Party Hard!"
    ```

    You can also change the suffix '_object', using the `:suffix` option:

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus,
                                                create_helpers: { polymorphic: { suffix: '_mode' } }
    end

    p.relationship_status_mode.saturday_night
    ```

*   The `:create_helpers` also creates some mutator helper methods, that can be
    used to change the attribute's value.

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus, create_helpers: true
    end

    p = Person.new
    p.married!

    p.married?
    #=> true

    p.divorced?
    #=> false
    ```

*   If you pass the `:create_scopes` option as `true`, it will create a scope
    method for each enumeration option (this option defaults to false):

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus, create_scopes: true
    end

    Person.married.to_sql
    #=> SELECT "people".* FROM "people" WHERE "people"."relationship_status" = 1
    ```

    The `:create_scopes` also accepts :prefix option.

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus,
                                                create_scopes: { prefix: true }
    end

    Person.relationship_status_married.to_sql
    ```

*   If your class can manage validations and responds to
    :validates_inclusion_of, it will create this validation:

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus
    end

    p = Person.new(relationship_status: 6) # there is no '6' value in the enumeration
    p.valid?
    #=> false
    p.errors[:relationship_status]
    #=> "is not included in the list"
    ```

*   If your class can manage validations and responds to
    `:validates_presence_of`, you can pass the :required options as true and
    this validation will be created for you (this option defaults to false):

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, required: true
    end

    p = Person.new relationship_status: nil
    p.valid?
    #=> false
    p.errors[:relationship_status]
    #=> "can't be blank"
    ```

* If you pass the `:skip_validation` option as `true`, it will not create any validations:

    ```ruby
    class Person < ActiveRecord::Base
      has_enumeration_for :relationship_status, with: RelationshipStatus, skip_validation: true
    end

    p = Person.new(relationship_status: 1_000_000)
    p.valid?
    #=> true
    ```

Remember that you can add validations to any kind of class and not only to
those derived from ActiveRecord::Base.

## I18n

I18n lookup is provided on both `_humanized` and `Enumeration#to_a` methods,
given the hash key is a Symbol. The I18n strings are located on
`enumerations.<enumeration_name>.<key>`:

```yaml
# Your locale file
pt:
  enumerations:
    relationship_status:
      married: Casado
```

```ruby
class RelationshipStatus < EnumerateIt::Base
  associate_values(
    married: 1,
    single: 2,
    divorced: [3, "He's divorced"]
  )
end

p = Person.new
p.relationship_status = RelationshipStatus::MARRIED
p.relationship_status_humanize
#=> 'Casado'

p.relationship_status = RelationshipStatus::SINGLE
p.relationship_status_humanize # nonexistent key
#=> 'Single'

p.relationship_status = RelationshipStatus::DIVORCED
p.relationship_status_humanize # uses the provided string
#=> 'He's divorced'
```

You can also translate specific values:

```ruby
RelationshipStatus.t(1)
#=> 'Casado'
```

## Installation

```bash
gem install enumerate_it
```

## Using with Rails

*   Add the gem to your Gemfile:

    ```ruby
    gem 'enumerate_it'
    ```

*   Run the install generator:

    ```bash
    rails generate enumerate_it:install
    ```

An interesting approach to use it in Rails apps is to create an
`app/enumerations` folder.

There is also a Rails Generator that you can use to generate enumerations and
their locale files. Take a look at how to use it running:

```bash
rails generate enumerate_it:enum --help
```

## Supported Ruby and Rails versions

Check [travis config file](https://github.com/lucascaton/enumerate_it/blob/master/.travis.yml).

## Why did you reinvent the wheel?

There are other similar solutions to the problem out there, but I could not
find one that worked both with strings and integers as the enumerations'
codes. I had both situations in my legacy database.

## Why defining enumerations outside the class that use it?

* I think it's cleaner.
* You can add behaviour to the enumeration class.
* You can reuse the enumeration inside other classes.

## Note on Patches/Pull Requests

*   Fork the project.
*   Make your feature addition or bug fix.
*   Add tests for it. This is important so I don't break it in a future
    version unintentionally.
*   Run the tests agaist all supported versions: `$ rake`.
*   Commit, do not mess with Rakefile, version, or history. (if you want to
    have your own version, that is fine but bump version in a commit by itself
    I can ignore when I pull)
*   Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010-2016 Cássio Marques and Lucas Caton. See LICENSE for details.
