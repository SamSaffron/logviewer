# Copyright (c) 2007 Michael Bryzek
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
module RemoteLogger
  module Helpers

    # Defines a local LRU cache. All operations are maintained in
    # constant size regardless of the size of the Cache. When creating
    # the cache, you specify the max size of the cache.
    #
    # Example:
    #   cache = Cache::LRU.new(:max_elements => 5)
    #    cache.put(:a, 1)
    #    cache[:a] = 2
    #    cache.get(:b) { 1 }
    #    cache[:b]
    class Cache

      include Enumerable

      attr_reader :size
      attr_reader :keys
      # opts:
      #  - max_elements - maximum number of elements to keep in the
      #    cache at any time. The default is 100 elements
      def initialize(opts = {})
        opts = { :max_elements => 100 }.merge(opts)
        @max_elements = opts.delete(:max_elements)
        raise "Invalid options: #{opts.keys.join(' ')}" if opts.keys.size > 0
        @keys = LinkedList.new
        @map = {}
        @size = 0
      end

      def clear!
        initialize( :max_elements => @max_elements )
      end
      
      # Iterates through all of the key/value pairs added to the cache,
      # in random order. Accepts a block that is yielded to with the key
      # and value for each entry in the cache.
      def each
        @map.each do |k, el| 
          yield k, el.value
        end
      end

      def [](key)
        get(key)
      end
      
      # Fetches the value of the element with the given key. If this key
      # does not exist in the cache, you can provide an optional code
      # block that we'll yield to to repopulate the value
      def get(key)
        if el = @map[key]
          @keys.move_to_head(el)
          return el.value
        elsif block_given?
          return put(key, yield)
        end
        return nil
      end

      def []=(key, value)
        put(key, value)
      end
      
      def put(key, value)
        el = @map[key]
        if el
          el.value = value
          @keys.move_to_head(el)
        else
          el = @keys.add(key, value)
          @size += 1
        end
        @map[key] = el

        if @size > @max_elements
          delete_element(@keys.last) 
          @size -= 1
        end
        value
      end

      def delete(key) 
        if el = @map[key]
          delete_element(el)
          @size -= 1
        else
          nil
        end
      end

      private
      def delete_element(el)
        @keys.remove_element(el)
        @map.delete(el.key)
        el.value
      end

    end

    class LinkedList

      attr_reader :last
      def initialize
        @head = @last = nil
      end

      def add(key, value)
        add_element(Element.new(key, value, @head))
      end

      def add_element(el)
        @head.previous_element = el if @head

        el.next_element = @head
        el.previous_element = nil
        @head = el
        @last = el unless @last
        el
      end

      def remove_element(el)
        el.previous_element.next_element = el.next_element if el.previous_element
        el.next_element.previous_element = el.previous_element if el.next_element

        @last = el.previous_element if el == @last
        @head = el.next_element if el == @head
      end

      def move_to_head(el)
        remove_element(el)
        add_element(el)
      end

      # Returns a nicely formatted stirng of all elements in the linked
      # list. First element is most recently used, last element is least
      # recently used.
      def pp
        s = ''
        el = @head
        while el
          s << ', ' if s.size > 0
          s <<  el.to_s
          el = el.next_element
        end
        s
      end

      class Element

        attr_accessor :key, :value, :previous_element, :next_element
        def initialize(key, value, next_element)
          @key = key
          @value = value
          @next_element = next_element
          @previous_element = nil
        end

        def inspect
          to_s
        end

        def to_s
          p = @previous_element ? @previous_element.key : 'nil'
          n = @next_element ? @next_element.key : 'nil'
          "[#{@key}: #{@value.inspect}, previous: #{p}, next: #{n}]"
        end

      end

    end
  end
end
