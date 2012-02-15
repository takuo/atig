# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig; end
module Atig::Agent; end

class Atig::Agent::ListStatus
  include Atig::Util

  def initialize(context, api, db)
    @log = context.log
    @db  = db
    log :info, "initialize"

    @prev = {}
    api.repeat(60*5) do|t|
      db.lists.each do |name, _|
        log :debug, "retrieve #{name} statuses"
        q = {}
        q.update(:since_id => @prev[name]) if @prev.key?(name)
        q.update(:include_rts => 1)

        screen_name,slug = parse name
        statuses = t.get("#{screen_name}/lists/#{slug}/statuses",q)
        statuses.reverse_each do|status|
          db.statuses.transaction do|d|
            d.add(:status => status,
                  :user => status.user,
                  :source => :list,
                  :list => name)
          end
        end
        @prev[name] = statuses[0].id if statuses && statuses.size > 0
      end
    end

    def parse(name)
      if name.include? '^' then
        name.split("^",2)
      else
        [@db.me.screen_name, name]
      end
    end
  end
end

