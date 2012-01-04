require 'active_support/concern'

module SocialStream #:nodoc:
  module Models
    # Common methods for models having many {SocialStream::Models::Subtype subtypes}.
    # Currently, there are two {SocialStream::Models::Supertype supertypes}:
    # * {Actor}: participates in the social network and has {Tie Ties} with other actors. Its subtypes are {SocialStream::Models::Subject subjects}, such as {User} or {Group}
    # * {ActivityObject}: created and managed by {Actor Actors} in {Activity Activities}. Its subtypes are {SocialStream::Models::Object objects}, like {Post} or {Comment}
    module Supertype
      extend ActiveSupport::Concern

      included do
        subtypes.each do |s|
          has_one s, :dependent => :destroy
        end
      end

      module ClassMethods
        def subtypes_name
          @subtypes_name
        end

        def subtypes
          SocialStream.__send__ subtypes_name.to_s.tableize # SocialStream.subjects # in Actor
        end
      end 

      module InstanceMethods
        def subtype_instance
          if __send__("#{ self.class.subtypes_name }_type").present?      # if object_type.present?
            object_class = __send__("#{ self.class.subtypes_name }_type") #   object_class = object_type # => "Video"
            __send__ object_class.constantize.base_class.to_s.underscore  #   __send__ "document"
                       end                                                # end
        end
      end

      module ActiveRecord
        extend ActiveSupport::Concern

        module ClassMethods
          # This class is a supertype. Subtype classes are known as name
          def supertype_of name
            @subtypes_name = name
            include SocialStream::Models::Supertype
          end
        end
      end
    end
  end
end
