describe 'YourLib'
  describe '.someMethod()'
    it 'should do something'
      true.should.be true
    end
    it 'should be ok'
      $('body').should.have_children 'div'
    end
  end
  describe 'xxxnotifications'
    before
      Sammy("#xxxflashes").trigger("flash", {msg: "haha"});
    end
    it 'xxxnotifications'
      $('.flashes-inlinedialog').find('.content').should.have_child '.flash-info'
    end
  end
end
