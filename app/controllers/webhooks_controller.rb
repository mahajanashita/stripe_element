class WebhooksController < ApplicationController
	skip_before_action :verify_authenticity_token
 #we use a webhook if their is any disconnect while payments they help resolve such infos
  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil
    endpoint_secret = "we_1JtWSlCNQtckV3FXG6tJBqF0"

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      render json: { message: 'invalid json' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: { message: 'signature verification failed' }, status: 400
      return
    end

    # Handle the event
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object # contains a Stripe::PaymentIntent

        #user with the stripe id there subcription status to active

      @user = User.find_by(stripe_customer_id: payment_intent.customer)
      @user.update(subscription_status: 'active')

      puts "PaymentIntent succeeded"
      @submission = Submission.find_by!(stripe_payment_id: payment_intent.id)
      @submission.update(status: 'paid')
      puts "Submission found: #{@submission.title}"

      # SubmissionMailer.receipt(@submission).deliver_later
      # SubmissionMailer.newsubmission(@submission).deliver_later
    else
      puts "Unhandled event type: #{event.type}"
    end

    render json: { message: 'success' }
  end

end
