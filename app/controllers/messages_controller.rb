class MessagesController < ApplicationController
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    @messages = Message.all.reverse
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create
    @message = Message.new(message_params)

    respond_to do |format|
      if @message.save
        format.turbo_stream do 

          render turbo_stream: [turbo_stream.update('new_message', 
                                partial: "messages/form", 
                                locals: { message: Message.new }), 
            turbo_stream.prepend('messages', 
                                partial: "messages/message", 
                                locals: { message: @message } )]
        end
        format.html { redirect_to message_url(@message), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @message }
      else
        # When we make the happy path use turbo stream, it's still necessary to consider what happens when 
        # there's an error, e.g. a failing form validation (due to presence - try submitting with no content)
        # In this case the form is re-rendered using turbo stream with the @message instance variable, which
        # contains whatever content the user tried to submit (in this case nothing but handles for any other
        # validations too).  
        format.turbo_stream do 
          render turbo_stream: [ 
            turbo_stream.update('new_message', 
                                partial: "messages/form", 
                                locals: { message: @message } )
          ]
        end 
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to message_url(@message), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:body)
    end
end
