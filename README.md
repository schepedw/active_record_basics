# Active Record Basics

This exercise is intended for you to get a little bit more familiar with
Active Record.

It is your job to implement the entity relations described below. You
will be able to do that without implementing any methods; all you should
need to do is declare relations within models. For anyone who is a
little rusty, these declarations look like `belongs_to`, and `has_many`.

## Setup
You'll need to run `rake db:create_roles` and `rake db:create` before you start creating migrations

## Migrations
There's no rails here, so running migrations isn't quite what you'd expect. There's a sample migration in `db/migrate/sample.rb`. To run your migrations, run `ruby db/migrate/migration_name.rb migration_method`.
For example, `ruby db/migrate/sample.rb up`

##Entity Relations

* A message has many tags
* A message has many attachments
* A message has one recipient
* A shipment has many recipients
* A shipment has many messages

## Additional requirements

Once you've implemented the relations above, begin modifying your code
to satisfy these requirements. You should still not need to do anything
besides declare relations in your models.


## Testing

#TODO - finish


### Misc Notes

I didn't know how to do active record without rails, there's a pretty
good tutorial for it
[here](http://blog.flatironschool.com/post/58164473975/connecting-ruby-active-record-without-rails)

