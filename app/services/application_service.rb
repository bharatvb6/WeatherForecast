#
# Base class for all service objects.
# Provides a standard `.call` interface.
#
class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end
end
