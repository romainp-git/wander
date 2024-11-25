SimpleForm.setup do |config|
  config.wrappers :default, class: 'mb-4', error_class: 'text-red-500' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.wrapper tag: 'div', class: 'flex flex-col' do |ba|
      ba.use :label, class: 'block text-sm font-medium text-gray-700'
      ba.use :input, class: 'mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm'
      ba.use :error, wrap_with: { tag: 'p', class: 'text-sm text-red-600 mt-2' }
      ba.use :hint, wrap_with: { tag: 'p', class: 'text-sm text-gray-500 mt-2' }
    end
  end

  config.default_wrapper = :default
end
