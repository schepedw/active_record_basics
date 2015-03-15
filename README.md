# Active Record Basics

This exercise is intended for you to get a little bit more familiar with
Active Record.

It is your job to implement the models described below. You
will be able to do that without implementing any methods; all you should
need to do is declare relations and validations within models. For anyone who is a
little rusty, relations look like `belongs_to`, and `has_many`.
There is a great resource [here](http://guides.rubyonrails.org/association_basics.html).
For validations, check out [this
guide](http://guides.rubyonrails.org/active_record_validations.html)

## Setup
You'll need to run `rake db:create_roles` and `rake db:create` before you start creating migrations

## Migrations
There's no rails here, so running migrations isn't quite what you'd expect. There's a sample migration in `db/migrate/sample.rb`. To run your migrations, run `ruby db/migrate/migration_name.rb migration_method`.
For example, `ruby db/migrate/sample.rb up`

## Validations
* An attachment requires content, file_type, and filename
* A message requires body
* A shipment requires from. If you want to get fancy, you could require
  this to be a `Contact`
* A contact has an email.
** Make sure contact emails are unique


##Entity Relations

* A message has many attachments
* A message has many recipients
* A shipment has many messages
* An attachment can have many messages
* A recipient can have many messages

## Additional requirements

Once you've implemented the relations above, begin modifying your code
to satisfy these requirements. You should still not need to do anything
besides declare relations and validations in your models.

* An attachment should know about the recipients it went to, and vice
  versa
⋅⋅ * But not directly! A attachment only goes to a recipient through a
`Message`
* A shipment should know about its attachments, and vice versa
⋅⋅ * But not directly! A shipment has messages, which have attachments.
* A shipment should know about its recipients
⋅⋅ * But not directly! A shipment has messages, which have recipients


## Testing

`bundle exec rspec`


### Resources

* You'll definitely need to be familiar with [Active Record
associations](http://guides.rubyonrails.org/association_basics.html)

* [This](http://guides.rubyonrails.org/active_record_validations.html) is a guide for Active Record
  Validations

* If you get super stuck, there is a branch on this repo called
  `dans_solution`. It's not entirely finished, but will be an excellent
start
* I didn't know how to do active record without rails, there's a pretty
good tutorial for it
[here](http://blog.flatironschool.com/post/58164473975/connecting-ruby-active-record-without-rails)
